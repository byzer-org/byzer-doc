# MongoDB

MongoDB is a widely used storage system. Byzer also supports loading one of these indexes as a table.

Note: the MongoDB package is not included in Byzer's default distribution, so you need to add the relevant dependencies via `--jars` to use it.

### Data load

**Example:**

```sql
> SET data='''{"jack":"cool"}''';

> LOAD jsonStr.`data` as data1;

> SAVE overwrite data1 AS mongo.`twitter/cool` WHERE
    partitioner="MongoPaginateBySizePartitioner"
    and uri="mongodb://127.0.0.1:27017/twitter";

> LOAD mongo.`twitter/cool` WHERE
    partitioner="MongoPaginateBySizePartitioner"
    and uri="mongodb://127.0.0.1:27017/twitter"
    AS table1;
> SELECT * FROM table1 AS output1;

> CONNECT mongo WHERE
    partitioner="MongoPaginateBySizePartitioner"
    and uri="mongodb://127.0.0.1:27017/twitter"
    AS mongo_instance;

> LOAD mongo.`mongo_instance/cool` AS table1;

> SELECT * FROM table1 AS output2;

> LOAD mongo.`cool` WHERE
    partitioner="MongoPaginateBySizePartitioner"
    and uri="mongodb://127.0.0.1:27017/twitter"
    AS table1;
> SELECT * FROM table1 AS output3;
```

> In MongoDB, the separator between data connection references and tables are not `.`, but `/`.

