# 在 Byzer 中加载数据源

阅读本章节前，请阅读 [Byzer-Lang 语言向导](/byzer-lang/zh-cn/grammar/outline.md) 以及 [数据加载/Load](/byzer-lang/zh-cn/grammar/load.md)。确保熟悉 Byzer 中数据加载相关的基本概念。

Byzer 的特性是 `Everything is a table`, 它具备加载和存储多种数据源的能力，数据源在 Byzer 的体系中，我们可以将其定义为 **输入**，这些数据源在 Byzer 中都可以抽象成一张带有 Schema 的二维表，供后续进行数据转换或模型训练使用。



Byzer 支持的外部数据源类型如下：
- [JDBC 数据源](/byzer-lang/zh-cn/datasource/jdbc/jdbc.md)
- [文件数据源](/byzer-lang/zh-cn/datasource/file/README.md)
    - [加载文件/文本](/byzer-lang/zh-cn/datasource/file/file.md)
    - [加载 HDFS 上的文件 ](/byzer-lang/zh-cn/datasource/file/hdfs.md)
    - [加载对象存储上的文件](/byzer-lang/zh-cn/datasource/file/object_storage.md)
- [数据仓库/湖](/byzer-lang/zh-cn/datasource/dw/README.md)
    * [加载 Hive](/byzer-lang/zh-cn/datasource/dw/hive.md)
    * [加载 Delta Lake](/byzer-lang/zh-cn/datasource/dw/delta_lake.md)
- [REST API](/byzer-lang/zh-cn/datasource/restapi/restapi.md)    
- [流式数据源](/byzer-lang/zh-cn/datasource/streaming/README.md)
    * [Kafka](/byzer-lang/zh-cn/datasource/streaming/kafka.md)
    * [MockStream](/byzer-lang/zh-cn/datasource/streaming/mock_streaming.md)
- [其他数据源](/byzer-lang/zh-cn/datasource/others/RAEDME.md)
    * [MySQL Binlog](/byzer-lang/zh-cn/datasource/others/mysql_binlog.md)
    * [ElasticSearch](/byzer-lang/zh-cn/datasource/others/es.md)
    * [Solr](/byzer-lang/zh-cn/datasource/others/solr.md)
    * [HBase](/byzer-lang/zh-cn/datasource/others/hbase.md)
    * [MongoDB](/byzer-lang/zh-cn/datasource/others/mongodb.md)

本章节我们会给出这些数据源的说明和使用示例。

