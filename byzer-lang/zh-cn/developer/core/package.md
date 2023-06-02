## 修改代码并打包示例

用户有可能需要临时修改 Byzer-lang 核心代码而非插件。这里我们简单介绍下如何修改代码并且打包，然后替换发行版。

### Byzer发行版目录结构

下面 Byzer 发行版的一个标准目录结构：

```
├── bin
│   ├── bootstrap.sh
│   ├── byzer
│   ├── byzer.sh
│   ├── check-1000-os.sh
│   ├── check-1100-java.sh
│   ├── check-1200-ports.sh
│   ├── check-env.sh
│   ├── get-properties.sh
│   ├── header.sh
│   ├── hello.byzer
│   └── kill-process-tree.sh
├── conf
│   ├── byzer.properties
│   ├── byzer.properties.all-in-one.example
│   ├── byzer.properties.override
│   ├── byzer.properties.server.example
│   ├── byzer-server-log4j2.properties
│   └── byzer-tools-log4j2.properties
├── jdk8
│   ├── ......
├── libs
│   ├── ansj_seg-5.1.6.jar
│   ├── .....
│   └── nlp-lang-1.7.8.jar
├── LICENSE
├── logs
│   ├── byzer-lang.log
│   ├── byzer.out
│   ├── check-env.error
│   ├── check-env.out
│   ├── security.log
│   ├── shell.stderr
│   ├── shell.stdout
│   └── template
├── main
│   └── byzer-lang-3.3.0-2.12-2.3.6.jar
├── plugin
│   ├── mlsql-assert-3.3_2.12-0.1.0-SNAPSHOT.jar
│   ├── .....
│   ├── mlsql-excel-3.3_2.12-0.1.0-SNAPSHOT.jar
├── README.md
├── RELEASES.md
├── spark
│   ├── activation-1.1.1.jar
│   ├── ....
│   └── zstd-jni-1.5.2-1.jar
├── spark-warehouse
└── store
    └── plugins
        └── byzer-llm-3.3_2.12-0.1.0-SNAPSHOT.jar

184 directories, 957 files
```

可以看到， Byzer 内置了 Spark/JDK 依赖。用户需要关注的核心三个目录是：

1. main   这里面其实只有一个包，类似： byzer-lang-3.3.0-2.12-2.3.6.jar， 由 byzer-lang项目打包而成。 
2. plugin 这里是Byzer的各种插件，一般都是通过shade方式打包的，一般是由 byzer-extension 项目打包而成。
3. libs   用户自主添加的第三方的一些依赖


今天我们给大家介绍如何对 Byzer-lang https://github.com/byzer-org/byzer-lang 项目进行修改和打包。

### 修改

参考 IDE 设置章节，设置好 IDE，并且可以在 IDE 启动 Byzer从而方便进行调试。

我们以 GBase 国产数据库为例，因为他对 JDBC 的 properties 有严格的属性校验，

而目前 Byzer 是可能会带一些额外的属性进去的，所以我们需要进行一些调整。

找到 `streaming.core.datasource.impl.MLSQLJDBC` ，该类是 Byzer 对 JDBC 数据源的一个封装。在加载 JDBC 数据源时的代码如下：

```scala
  override def load(reader: DataFrameReader, config: DataSourceConfig): DataFrame = {
    var dbTable = config.path
    // if contains splitter, then we will try to find dbname in dbMapping.
    // otherwize we will do nothing since elasticsearch use something like index/type
    // it will do no harm.
    val format = config.config.getOrElse("implClass", fullFormat)
    var driver: Option[String] = config.config.get("driver")
    var url = config.config.get("url")
    if (config.path.contains(dbSplitter)) {
      val Array(_dbname, _dbTable) = config.path.split(toSplit, 2)
      ConnectMeta.presentThenCall(DBMappingKey(format, _dbname), options => {
        dbTable = _dbTable
        reader.options(options)
        url = options.get("url")
        driver = options.get("driver")
      })
    }
    //load configs should overwrite connect configs
    reader.options(config.config)
```

我们可以看到，他会把所有 connect 语法中的where参数以及 load 语句中的where 条件都放到 reader.options中，而这个reader.options 参数会传递给底层的 JDBC 驱动，这样就会触发错误。

通常我们会加入如下额外的属性：

1. format
2. directQuery

这两个属性是 config.config 带入的。所以可以修改最后一行代码：

```scala
reader.options(config.config - "format" - "directQuery")
```

实际报错如果还有额外属性，可以继续像上面一样增加。

### 打包

Byzer-lang 提供了打包脚本,在 Byzer-lang 更目录下执行如下代码即可打包：

```shell
export BYZER_LANG_VERSION=2.3.6
export SPARK_VERSION=3.3.0
export DISTRIBUTION=true

mvn versions:set -DnewVersion=${BYZER_LANG_VERSION}
./dev/package.sh
```

接着解压:


```shell
tar xvf byzer-lang-3.3.0-2.3.6.tar.gz
```

此时在 main 包里，你就可以得到主jar包 byzer-lang-3.3.0-2.12-2.3.6.jar， 然后其替换你线上的对应jar包，重启即可。

