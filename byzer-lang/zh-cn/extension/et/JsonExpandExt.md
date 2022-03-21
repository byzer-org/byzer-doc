# Json 展开插件 JsonExpandExt 
数据处理中，JSON 数据很常见的，例如埋点数据。Hive 和 Spark 均提供了 JSON 处理函数，
使用 Byzer 插件，可以方便地将一个 JSON 字段展开为多个字段。
下面以例子介绍其使用方式。

### 示例
- 查看帮助

```sql
load modelExample.`JsonExpandExt` AS output;
```

- 例子1：JSON 没有嵌套

```sql
SELECT '{"name":"Michael"}' AS col_1
UNION ALL
SELECT '{"name":"Andy", "age":30}' AS col_1 AS table_1;

run table_1 as JsonExpandExt.`` where inputCol="col_1" AND samplingRatio = "1.0" as table_2;
```

结果如下

|name | age| 
|---|---|
|Michael | |
|Andy |30|

inputCol 表示 JSON 字段 col_1。samplingRatio 指系统采样分析 JSON 结构的采样率，为大于 0 小于 1 的小数。

- 例子2：嵌套的 JSON

```sql
SELECT '{"name":"Michael", "address":{"city":"hangzhou", "district":"xihu"} } ' AS col_1 AS table_1;
run table_1 as JsonExpandExt.`` where inputCol="col_1" AND samplingRatio = "1.0" as table_2;
run table_2 AS JsonExpandExt.`` WHERE inputCol="address" AS table_3;
```

结果如下

|name|city|district|
|---|---|---|
|Michael|hangzhou|xihu|

本例子的 city 嵌套在第二层，因而需要执行两次 run 语句。

