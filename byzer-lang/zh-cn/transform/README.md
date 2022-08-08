# 使用 Byzer 处理数据

Byzer 语言为用户提供了基于 SQL 的语法来处理数据。用户可以通过 [SELECT 语法](/byzer-lang/zh-cn/grammar/select.md)来将 `LOAD` 进系统中的表进行转化。

一般来说，当用户通过 `LOAD` 语句或通过[文本数据源](/byzer-lang/zh-cn/datasource/file/file.md) 在系统中加载一个表后，那么就可以使用 SQL 的方式或通过[执行 ET 扩展](/byzer-lang/zh-cn/extension/et/README.md) 的方式来进行数据的转化和计算。

如果当现有的 SQL 函数， UDF 或 ET 都无法满足使用需求的时候，用户可以通过自行扩展 UDF 或 ET 的方式来增强系统的能力


- [SQL 函数](/byzer-lang/zh-cn/transform/sql_func/README.md)
- [UDF 扩展](/byzer-lang/zh-cn/transform/udf/README.md)
* [系统内置 UDF](/byzer-lang/zh-cn/transform/udf/built_in_udf/README.md)
    * [http 请求](/byzer-lang/zh-cn/transform/udf/built_in_udf/http.md)
    * [常用函数](/byzer-lang/zh-cn/transform/udf/built_in_udf/udf_funcs.md)
* [动态扩展 UDF](/byzer-lang/zh-cn/transform/udf/extend_udf/README.md)
    * [Python UDF](/byzer-lang/zh-cn/transform/udf/extend_udf/python_udf.md)
    * [Scala UDF](/byzer-lang/zh-cn/transform/udf/extend_udf/scala_udf.md)
    * [Scala UDAF](/byzer-lang/zh-cn/transform/udf/extend_udf/scala_udaf.md)
    * [Java UDF](/byzer-lang/zh-cn/transform/udf/extend_udf/java_udf.md)  
* [Estimator-Transformer 插件](/byzer-lang/zh-cn/extension/et/README.md)
    * 内置 ET 插件
        * [缓存表插件/CacheExt](/byzer-lang/zh-cn/extension/et/CacheExt.md)
        * [Json 展开插件/JsonExpandExt](/byzer-lang/zh-cn/extension/et/JsonExpandExt.md)
        * [Byzer-Watcher 插件](/byzer-lang/zh-cn/extension/et/byzer-watcher.md)
        * [发送邮件插件/SendMessage](/byzer-lang/zh-cn/extension/et/SendMessage.md)
        * [语法解析插件/SyntaxAnalyzeExt](/byzer-lang/zh-cn/extension/et/SyntaxAnalyzeExt.md)
        * [表分区插件/TableRepartition](/byzer-lang/zh-cn/extension/et/TableRepartition.md)
        * [计算表父子关系插件/TreeBuildExt](/byzer-lang/zh-cn/extension/et/TreeBuildExt.md)
    * 外置 ET 插件
        * [Connect语句持久化](/byzer-lang/zh-cn/extension/et/external/connect-persist.md)
        * [Byzer 断言](/byzer-lang/zh-cn/extension/et/external/mlsql-assert.md)
        * [Byzer mllib](/byzer-lang/zh-cn/extension/et/external/mlsql-mllib.md)
        * [shell 命令插件](/byzer-lang/zh-cn/extension/et/external/mlsql-shell.md)
        * [将字符串当做代码执行](/byzer-lang/zh-cn/extension/et/external/run-script.md)
        * [保存到增量表中再次加载](/byzer-lang/zh-cn/extension/et/external/save-then-load.md)