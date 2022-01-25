# Data save/Save

The `save` statement is similar to the `insert` statement in traditional SQL. But like the `load` statement, Byzer-Lang will connect various data source types, such as object storage and database tables, it is not only limited to data warehouses. The `insert` statement is too complicated and cannot satisfy this requirement. So Byzer-Lang provides a new `save` statement for data storage.

## Basic syntax 

```sql
set rawData='''
{"jack":1,"jack2":2}
{"jack":2,"jack2":3}
''';
load jsonStr.`rawData` as table1;
save overwrite table1 as json.`/tmp/jack`;
```

The last statement is the `save` statement.

The meaning of the above `save` statement is: overwrite `table1` and save in Json format, and the save location is `/tmp/jack`.

Usually, the data source or format in the `save` statement is the same as that in `load`, and the configuration parameters are similar.

But some data sources only support `save`, while some others only support `load`. For example, `jsonStr` only supports `load`, but not `save`.

The `save` statement also supports the `where/options` conditional clause. For example, if users want to control the number of files when saving, they could use the `fileNum` parameter in the `where/options` clause:

```sql
save overwrite table1 as json.`/tmp/jack` where fileNum="10";
```

## Save methods

`save` supports four saving methods:

1. overwrite: to overwrite the file
2. append: append write
3. ignore: if file exits, skip it and do not overwrite
4. errorIfExists: if file exits, report an error

## Support to `connect`
`save` also supports citing of `connect` statements.

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

The `connect` statement is not to connect to the database, but just to facilitate subsequent saving in the same data source, so you do not need to fill the same parameters repeatedly in the `load/save` statement.

For the `connect` statement in the example, `jdbc + db_1` is the unique tag. When the system encounters `jdbc.db_1.crawler_table` in the  `save` statement, it will find all configuration parameters through jdbc and db_1, such as driver, user, url, etc, then automatically add to the `save` statement.