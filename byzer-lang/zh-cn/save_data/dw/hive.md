# 写入 Hive

> 关于如何配置 Hive 以及如何加载 Hive 中的表，请参考 [Hive 数据源](/byzer-lang/zh-cn/datasource/dw/hive.md)

当在 Byzer 中对表进行处理后，我们可以通过 `SAVE` 语句来将临时虚拟表存入至 Hive 当中

### 将表写入至 Hive

`SAVE` 语句支持 `overwrite` 和 `append` 两种方式来将表存储至 Hive 中
- `overwrite` 会覆盖表的 Schema 和内容进行覆写
- `append` 是追加表至 Hive 中的表，需要要求 Schema 保持一致



将表保存至 Hive：

```sql
save overwrite table1 as hive.`db.table1`;
```

如果需要分区，则使用

```sql
save overwrite table1 as hive.`db.table1` partitionBy col1;
```

### 使用数据湖代理 Hive

我们也可以使用数据湖替换实际的 Hive 存储：

在 `$BYZER_HOME/conf/byzer.properties.override` 配置文件中配置如下参数


1. 启动时配置 `-streaming.datalake.path` 参数,启用数据湖。
2. 配置 `-spark.mlsql.datalake.overwrite.hive` Hive 采用数据湖存储。

使用时如下：

```sql
set rawText='''
{"id":9,"content":"Spark好的语言1","label":0.0}
{"id":10,"content":"MLSQL 是一个好的语言6","label":0.0}
{"id":12,"content":"MLSQL 是一个好的语言7","label":0.0}
''';

load jsonStr.`rawText` as orginal_text_corpus;

select cast(id as String)  as rowkey,content,label from orginal_text_corpus as orginal_text_corpus1;
save overwrite orginal_text_corpus1 as hive.`public.orginal_text_corpus1`;

load hive.`public.orginal_text_corpus1` as output ;
```

这样当对 Hive 实现存储时，会有一些优缺点，在你访问 Hive 时，如果数据湖里没有，则会穿透数据湖，返回 Hive 结果。

如果你希望在写入的时候一定要写入到 Hive 的存储当中而不是写入至数据湖里，可以通过在 where 语句中强行指定 `storage` 为 `hive`

```sql
> save overwrite orginal_text_corpus1 as hive.`public.orginal_text_corpus1` where storage="hive"; 
```

