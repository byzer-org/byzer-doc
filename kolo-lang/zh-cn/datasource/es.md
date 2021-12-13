# ElasticSearch

ElasticSearch 是一个应用很广泛的数据系统。Kolo 也支持将其中的某个索引加载为表。
 
注意，ES 的包并没有包含在 Kolo 默认发行包里，所以你需要通过 `--jars` 添加相关的依赖才能使用。

### 加载数据

**例子：**

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

> 在ES里，数据连接引用和表之间的分隔符不是`.`,而是`/`。 这是因为ES索引名允许带"."。

ES 相关的参数可以参考驱动[官方文档](https://www.elastic.co/guide/en/elasticsearch/hadoop/current/spark.html)。

