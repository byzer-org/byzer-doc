# Solr

Solr 是一个应用很广泛的存储。Kolo 也支持将其中的某个索引加载为表。

注意，Solr 的包并没有包含在 Kolo 默认发行包里，所以你需要通过 `--jars` 带上相关的依赖才能使用。

## 加载数据

示例：

```sql
> SELECT 1 AS id, "this is mlsql_example" AS title_s AS mlsql_example_data;

> CONNECT solr WHERE `zkhost`="127.0.0.1:9983"
and `collection`="mlsql_example"
and `flatten_multivalued`="false"
AS solr1
;

> LOAD solr.`solr1/mlsql_example` AS mlsql_example;

> SAVE mlsql_example_data AS solr.`solr1/mlsql_example`
OPTIONS soft_commit_secs = "1";
```

>在 Solr 里，数据连接引用和表之间的分隔符不是`.`,而是`/`。 这是因为Solr索引名允许带"."。

所有 Solr 相关的参数可以参考驱动[官方文档](https://github.com/lucidworks/spark-solr)。

