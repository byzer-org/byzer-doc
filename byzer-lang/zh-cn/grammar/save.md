# 保存数据/save

`save` 句式类似传统 SQL 中的 `insert` 语法。但同 `load` 语法一样，Byzer-lang 是要面向各种数据源的，譬如各种对象存储，亦或是各种类型的库表，不仅仅局限在数仓。`insert` 语法无法很好的满足该诉求，
同时 `insert` 语法过于繁琐，所以 Byzer-lang 提供了新的 `save` 句式专门应对数据存储。

## 基本语法

```sql
set rawData='''
  {"jack":1,"jack2":2}
  {"jack":2,"jack2":3}
''';
load jsonStr.`rawData` as table1;
save overwrite table1 as json.`/tmp/jack`;
```

最后一句就是 `save` 句式了。 

上面的 `save` 语句的含义是： 将 `table1` 进行覆盖保存，存储的格式为 Json 格式，保存位置是 `/tmp/jack`。 

通常，`save` 语句里的数据源或者格式和 `load` 是保持一致的，配置参数也几乎保持一致。

但有部分数据源只支持 `save`,有部分只支持 `load`。典型的比如 `jsonStr` 就只支持 `load`,而不支持`save`。

`save` 语句也支持 `where/options` 条件子句。比如，如果用户希望保存时控制文件数量，那么可以使用 `where/options` 子句中的 `fileNum` 参数
进行控制：

```sql
save overwrite table1 as json.`/tmp/jack` where fileNum="10";
```

## Save 保存方式

`save` 支持四种存储方式：

1. overwrite：覆盖写
2. append：追加写
3. ignore：文件存在，跳过不写
4. errorIfExists：文件存在，则报错

## Save Connect 支持
`save` 也支持 `connect` 语句的引用。

比如：

```sql

select 1 as a as tmp_article_table;

connect jdbc where
url="jdbc:mysql://127.0.0.1:3306/wow?characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&tinyInt1isBit=false"
and driver="com.mysql.jdbc.Driver"
and user="xxxxx"
and password="xxxxx"
as db_1;

save append tmp_article_table as jdbc.`db_1.crawler_table`;
```

`connect` 语句并不是真的去连接数据库，而仅仅是方便后续记在同一数据源，避免在 `load/save` 句式中反复填写相同的参数。

对于示例中的 `connect` 语句， jdbc + db_1 为唯一标记。 当系统遇到下面 `save` 语句中 jdbc.`db_1.crawler_table` 时，他会通过 jdbc 以及 db_1 找到所有的配置参数， 如 driver， user, url, 等等，然后自动附带上到 `save` 语句中。
