# HBase 数据源

HBase 是一个应用很广泛的存储系统。Byzer 也支持将其中的某个索引加载为表。

注意，HBase 的包并没有包含在 Byzer 默认发行包里，所以你需要通过 `--jars` 带上相关的依赖才能使用。用户有两种种方式获得
HBase Jar包：

1. ~~直接使用 [hbase Datasource 插件](https://github.com/allwefantasy/mlsql-pluins/tree/master/ds-hbase-2x)~~；
   (暂不支持)
2. 访问 [spark-hbase](https://github.com/allwefantasy/spark-hbase) ,然后手动进行编译；

##  安装及使用

### ~~插件安装~~(暂不支持)

通过如下指令安装 `ds-hbase-2x` ：

```sql
> !plugin ds add tech.mlsql.plugins.ds.MLSQLHBase2x ds-hbase-2x;
```                                                           

因为 HBase 依赖很多，大概 80 多 M,下载会比较慢。

### 在 Byzer 中执行

**例子:**

```sql
> SET rawText='''
{"id":9,"content":"Spark","label":0.0}
{"id":10,"content":"Byzer","label":0.0}
{"id":12,"content":"Byzer lang","label":0.0}
''';

> LOAD jsonStr.`rawText` AS orginal_text_corpus;

> SELECT cast(id as String) AS rowkey,content,label FROM orginal_text_corpus AS orginal_text_corpus1;

-- connect 后面接数据格式，这里是 hbase2x, 然后后面接一些配置。最后将这个连接命名为 hbase1. 
> CONNECT hbase2x WHERE `zk`="127.0.0.1:2181"
and `family`="cf" AS hbase1;

> SAVE overwrite orginal_text_corpus1 
AS hbase2x.`hbase1:kolo_example`;

> LOAD hbase2x.`hbase1:kolo_example` WHERE field.type.label="DoubleType"
AS kolo_example;

> SELECT * FROM kolo_example AS show_data;

```

**DataFrame 代码:**

```scala
val data = (0 to 255).map { i =>
      HBaseRecord(i, "extra")
    }
val tableName = "t1"
val familyName = "c1"


import spark.implicits._
sc.parallelize(data).toDF.write
  .options(Map(
    "outputTableName" -> cat,
    "family" -> family
  ) ++ options)
  .format("org.apache.spark.sql.execution.datasources.hbase2x")
  .save()
  
val df = spark.read.format("org.apache.spark.sql.execution.datasources.hbase2x").options(
  Map(
    "inputTableName" -> tableName,
    "family" -> familyName,
    "field.type.col1" -> "BooleanType",
    "field.type.col2" -> "DoubleType",
    "field.type.col3" -> "FloatType",
    "field.type.col4" -> "IntegerType",
    "field.type.col5" -> "LongType",
    "field.type.col6" -> "ShortType",
    "field.type.col7" -> "StringType",
    "field.type.col8" -> "ByteType"
  )
).load() 
```         

## 配置参数

ds-hbase-2x 的配置参数如下表：

| 参数名  |  参数含义 |
|---|---|
| tsSuffix | 覆盖 Hbase 值的时间戳 |
|namespace|Hbase namespace|
| family |Hbase family，`family=""` 表示加载所有存在的 family |
| field.type.ck | 为 `ck(field name)` 指定类型，现在支持：LongType、FloatType、DoubleType、IntegerType、BooleanType、BinaryType、TimestampType、DateType，默认为: StringType |