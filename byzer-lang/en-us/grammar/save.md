# Data Save/Save

The `save` syntax is similar to the `insert` syntax in traditional SQL. But like the `load` syntax, Byzer-lang is applicable for various data sources, such as various object storage, or various types of database tables, it is not only limited to data warehouses. The `insert` syntax cannot satisfy this requirement well. At the same time, the `insert` syntax is too cumbersome, so Byzer-lang provides a new `save` syntax for data storage.

## Basic grammar

```sql
set rawData='''
{"jack":1,"jack2":2}
{"jack":2,"jack2":3}
''';
load jsonStr.`rawData` as table1;
save overwrite table1 as json.`/tmp/jack`;
```

The last sentence is the `save` syntax.

The meaning of the above `save` syntax is: overwrite `table1` and save, the storage format is Json and the storage location is `/tmp/jack`.

Usually, the data source or format in the `save` statement is the same as that in `load`, and the configuration parameters are almost the same.

But some data sources only support `save`, and some only support `load`. Typically, `jsonStr` only supports `load`, but not `save`.

The `save` statement also supports the `where/options` conditional clause. For example, if users want to control the number of files when saving, the `fileNum` parameter in the `where/options` clause can be used to control it:

```sql
save overwrite table1 as json.`/tmp/jack` where fileNum="10";
```

## Save method

`save` supports four storage methods:

1. overwrite
2. append: append write
3. ignore: if file exits, skip it and do not write
4. errorIfExists: if file exits, an error is reported

## Save Connect support
`save` also supports quoting of `connect` statements.

For example:

```sql

select 1 as a as tmp_article_table

connect jdbc where
url="jdbc:mysql://127.0.0.1:3306/wow?characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&tinyInt1isBit=false"
and driver="com.mysql.jdbc.Driver"
and user="xxxxx"
and password="xxxxx"
as db_1;

save append tmp_article_table as jdbc.`db_1.crawler_table`;
```

The `connect` statement is not to connect to the database, but just to facilitate subsequent records in the same data source. It avoids filling in the same parameters repeatedly in the `load/save` statement.

For the `connect` statement in the example, jdbc + db_1 is the unique mark. When the system encounters jdbc.`db_1.crawler_table` in the following `save` statement, it will find all configuration parameters through jdbc and db_1 such as driver, user, url, etc.. Then it automatically appended to the `save` statement.