## Kolo 数据源开发指南

### 前言
Kolo 支持标准的 Spark DataSource 数据源。典型使用如下：

```sql
load hive.`public.test` as test;
 
set data='''
{"key":"yes","value":"no","topic":"test","partition":0,"offset":0,"timestamp":"2008-01-24 18:01:01.001","timestampType":0}
''';
 
-- load data as table
load jsonStr.`data` as datasource;
 
select * from datasource as table1;
```
那么我们如何实现自己的数据源呢？下面我们会分两部分，第一部分是已经有第三方实现了的标准 Spark 数据源的集成，第二个是你自己创造的新的数据源。

标准 Spark 数据源的在封装
我们以 HBase 为例，这是一个已经实现了标准Spark数据源的驱动，对应的类为`org.apache.spark.sql.execution.datasources.hbase`。 现在我们要把他封装成 Kolo 能够很好兼容的数据源。

我们先看看具体使用方法

```sql
--设置链接信息
connect hbase where `zk`="127.0.0.1:2181"
and `family`="cf" as hbase1;
 
-- 加载hbase 表
load hbase.`hbase1:mlsql_example`
as mlsql_example;
 
select * from mlsql_example as show_data;
 
 
select '2' as rowkey, 'insert test data' as name as insert_table;
 
-- 保存数据到hbase表
save insert_table as hbase.`hbase1:mlsql_example`;
```
为了实现上述 Kolo 中的 hbase 数据源，我们只要实现创建一个类实现一些接口就可以实现上述功能：

```python
package streaming.core.datasource.impl
class MLSQLHbase(override val uid: String) extends MLSQLSource with MLSQLSink  with MLSQLRegistry with WowParams {
  def this() = this(BaseParams.randomUID())
```
你需要保证你的包名和上面一致，也就是 streaming.core.datasource.impl 或者是 streaming.contri.datasource.impl，其次类的名字你随便定义，我们这里定义为 MLSQLHBase。 他需要实现一些接口：

MLSQLSource 定义了数据源的名字，实现类以及如何进行数据装载。
MLSQLSink 定义了如何对数据进行存储。
MLSQLRegistry 注册该数据源
WowParams 可以让你暴露出你需要的配置参数。也就是 load/save 语法里的 where 条件。
实现 load 语法
先看看 MLSQLSource 多有哪些接口要实现：

```scala
 trait MLSQLDataSource {
  def dbSplitter = {
    "."
  }
 
  def fullFormat: String
 
  def shortFormat: String
 
  def aliasFormat: String = {
    shortFormat
  }
 
}
 
trait MLSQLSourceInfo extends MLSQLDataSource {
  def sourceInfo(config: DataAuthConfig): SourceInfo
 
  def explainParams(spark: SparkSession): DataFrame = {
    import spark.implicits._
    spark.createDataset[String](Seq()).toDF("name")
  }
}
 
trait MLSQLSource extends MLSQLDataSource with MLSQLSourceInfo {
  def load(reader: DataFrameReader, config: DataSourceConfig): DataFrame
}
```
可以看到 MLSQLSource 需要实现的方法比较多，我们一个一个来介绍：

```scala
def dbSplitter = {
    "."
  }
 
  def fullFormat: String
 
  def shortFormat: String
 
  def aliasFormat: String = {
    shortFormat
  }
 ```
dbSplitter 定义了库表的分割符号，默认是., 但比如 hbase 其实是:。 fullFormat 是你完整的数据源名字，shortFormat 则是短名。aliasFormat 一般和 shortFormat 保持一致。

这里我们覆盖实现结果如下：

```scala
 override def fullFormat: String = "org.apache.spark.sql.execution.datasources.hbase"
 
  override def shortFormat: String = "hbase"
 
  override def dbSplitter: String = ":"
```
接着是 sourceInfo 方法，它的作用主要是提取真实的库表，比如 hbase 的命名空间和表名。这里是我们HBase 的实现：

入参 config: DataAuthConfig：

config 参数主要有三个值，分别是 path，config 和 df . path 其实就是`load hbase.\jack`` ... `中的 jack， config 是个 Map，其实就是 where 条件形成的，df 则可以让你拿到 spark 对象。

ConnectMeta.presentThenCall 介绍：

`ConnectMeta.presentThenCall` 可以让你拿到 connect 语法里的所有配置选项，然后和你 load 语法里的 where 条件进行合并从而拿到所有的配置选项。

```scala
override def sourceInfo(config: DataAuthConfig): SourceInfo = {   
    val Array(_dbname, _dbtable) = if (config.path.contains(dbSplitter)) {
      config.path.split(dbSplitter, 2)
    } else {
      Array("", config.path)
    }
 
    var namespace = _dbname
 
    if (config.config.contains("namespace")) {
      namespace = config.config.get("namespace").get
    } else {
      if (_dbname != "") {
        val format = config.config.getOrElse("implClass", fullFormat)
       //获取connect语法里的信息
        ConnectMeta.presentThenCall(DBMappingKey(format, _dbname), options => {
          if (options.contains("namespace")) {
            namespace = options.get("namespace").get
          }
        })
      }
    }
 
    SourceInfo(shortFormat, namespace, _dbtable)
  }
```
现在实现注册方法：

```scala
override def register(): Unit = {
    DataSourceRegistry.register(MLSQLDataSourceKey(fullFormat, MLSQLSparkDataSourceType), this)
    DataSourceRegistry.register(MLSQLDataSourceKey(shortFormat, MLSQLSparkDataSourceType), this)
  }
```
大家照着写就行。

最后实现最核心的 load 方法：

```scala
override def load(reader: DataFrameReader, config: DataSourceConfig): DataFrame = {
    val Array(_dbname, _dbtable) = if (config.path.contains(dbSplitter)) {
      config.path.split(dbSplitter, 2)
    } else {
      Array("", config.path)
    }
 
    var namespace = ""
 
    val format = config.config.getOrElse("implClass", fullFormat)
  // 获取connect语法里的所有配置参数
    if (_dbname != "") {
      ConnectMeta.presentThenCall(DBMappingKey(format, _dbname), options => {
        if (options.contains("namespace")) {
          namespace = options("namespace")
        }
        reader.options(options)
      })
    }
 
    if (config.config.contains("namespace")) {
      namespace = config.config("namespace")
    }
 
    val inputTableName = if (namespace == "") _dbtable else s"${namespace}:${_dbtable}"
 
    reader.option("inputTableName", inputTableName)
 
    //load configs should overwrite connect configs
    reader.options(config.config)
    reader.format(format).load()
  }
```
上面的代码其实就是调用了标准的 spark datasource api 进行操作的。

实现 Save 语法

```scala
trait MLSQLSink extends MLSQLDataSource {
  def save(writer: DataFrameWriter[Row], config: DataSinkConfig): Any
}
```
因为前面我们已经了  MLSQLDataSource需要的方法，所以现在我们只要是实现 save 语法即可，很简单，也是调用标准的 datasource api 完成写入：

```scala
override def save(writer: DataFrameWriter[Row], config: DataSinkConfig): Unit = {
    val Array(_dbname, _dbtable) = if (config.path.contains(dbSplitter)) {
      config.path.split(dbSplitter, 2)
    } else {
      Array("", config.path)
    }
 
    var namespace = ""
 
    val format = config.config.getOrElse("implClass", fullFormat)
    if (_dbname != "") {
      ConnectMeta.presentThenCall(DBMappingKey(format, _dbname), options => {
        if (options.contains("namespace")) {
          namespace = options.get("namespace").get
        }
        writer.options(options)
      })
    }
 
    if (config.config.contains("namespace")) {
      namespace = config.config.get("namespace").get
    }
 
    val outputTableName = if (namespace == "") _dbtable else s"${namespace}:${_dbtable}"
 
    writer.mode(config.mode)
    writer.option("outputTableName", outputTableName)
    //load configs should overwrite connect configs
    writer.options(config.config)
    config.config.get("partitionByCol").map { item =>
      writer.partitionBy(item.split(","): _*)
    }
    writer.format(config.config.getOrElse("implClass", fullFormat)).save()
  }
```
### 最后
最后我们定义我们都可以接受那些常用的配置参数

```scala
override def explainParams(spark: SparkSession) = {
    _explainParams(spark)
  }
 
  final val zk: Param[String] = new Param[String](this, "zk", "zk address")
  final val family: Param[String] = new Param[String](this, "family", "default cf")
```

实现 loadJson
具体的语法如下：

```sql
set data='''
{"key":"yes","value":"no","topic":"test","partition":0,"offset":0,"timestamp":"2008-01-24 18:01:01.001","timestampType":0}
''';
 
-- load data as table
load jsonStr.`data` as datasource;
 
select * from datasource as table1;
```
实现相当简单：

```scala
class MLSQLJSonStr(override val uid: String) extends MLSQLBaseFileSource with WowParams {
  def this() = this(BaseParams.randomUID())
 
 
  override def load(reader: DataFrameReader, config: DataSourceConfig): DataFrame = {
    val context = ScriptSQLExec.contextGetOrForTest()
    val items = cleanBlockStr(context.execListener.env()(cleanStr(config.path))).split("\n")
    val spark = config.df.get.sparkSession
    import spark.implicits._
    reader.options(rewriteConfig(config.config)).json(spark.createDataset[String](items))
  }
 
  override def save(writer: DataFrameWriter[Row], config: DataSinkConfig): Unit = {
    throw new RuntimeException(s"save is not supported in ${shortFormat}")
  }
 
  override def register(): Unit = {
    DataSourceRegistry.register(MLSQLDataSourceKey(fullFormat, MLSQLSparkDataSourceType), this)
    DataSourceRegistry.register(MLSQLDataSourceKey(shortFormat, MLSQLSparkDataSourceType), this)
  }
 
  override def fullFormat: String = "jsonStr"
 
  override def shortFormat: String = fullFormat
 
}
```
