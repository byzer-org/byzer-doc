# Solr

Solr is a widely used search server. Byzer also supports loading one of these indexes as a table.

Note: the Solr package is not included in Byzer's default distribution, so you need to add the relevant dependencies via `--jars` to use it.

### Data load

Example:

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

> In Solr, the separators between data connection references and tables are not `.`, but `/`. This is because Solr index names are allowed to use `.`.

For more information, read [official documentation](https://github.com/lucidworks/spark-solr).

