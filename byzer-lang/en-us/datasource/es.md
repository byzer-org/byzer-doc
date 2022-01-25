# Elasticsearch

Elasticsearch is a widely used data system. Byzer also supports loading one of these indexes as a table.

Note: ES packages are not included in Byzer's default distribution, so you need to add relevant dependencies via `--jars` to use them.

### Data load

**Example:**

```sql
> SET data='''{"jack":"cool"}''';
> LOAD jsonStr.`data` AS data1;

> SAVE overwrite data1 AS es.`twitter/cool` WHERE
`es.index.auto.create`="true"
and es.nodes="127.0.0.1";

> LOAD es.`twitter/cool` WHERE
and es.nodes="127.0.0.1" AS table1;

> SELECT * FROM table1 AS output1;

> CONNECT es WHERE  `es.index.auto.create`="true"
and es.nodes="127.0.0.1" AS es_instance;

> LOAD es.`es_instance/twitter/cool` AS table1;
> SELECT * FROM table1 AS output2;
```

> In ES, the separator between the data connection reference and the table is not`.`, but`/`. This is because ES index names are allowed to use `.`.

For more information, read [official documentation](https://www.elastic.co/guide/en/elasticsearch/hadoop/current/spark.html).

