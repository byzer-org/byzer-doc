# REST API 数据源

REST API 是 Byzer-lang 的一个核心特性功能，能够使得用户可以通过一条 `load` 语句，将一个 REST API 的返回结果进行解析后，映射为一张二维表。

一般而言，对于常见系统的 REST API 返回，无论是什么请求，都会将结果通过 json 的方式来封装返回体，json 是一个 key-value 格式的具备 schema 的文本内容，Byzer 可以将 json 的 schema 进行打平，将 key 作为结果表的列 （table column），将 value 作为结果表的行 （row）。



- [加载 REST API 数据源](/byzer-lang/zh-cn/datasource/restapi/restapi.md)
