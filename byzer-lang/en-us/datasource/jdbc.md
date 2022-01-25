# JDBC data source

Byzer supports loading data sources that conform to the JDBC protocol such as MySQL, Oracle, Hive thrift server, etc..

This article will introduce MySQL as the main example.

## Data load

Byzer supports for establishing connection to JDBC data sources by using the `connect` syntax and the `load` syntax.

Note: the established connection is valid within the scope of the APP.

Here is an example using the `connect` syntax:

```sql
> SET user="root";
> SET password="root";
> CONNECT jdbc WHERE
 url="jdbc:mysql://127.0.0.1:3306/wow?characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&tinyInt1isBit=false"
 and driver="com.mysql.jdbc.Driver"
 and user="${user}"
 and password="${password}"
 AS db_1;
```

> This statement indicates that Byzer connects to a JDBC data source. The `WHERE` statement contains connection-related parameters, specifies that the driver is the MySQL driver, and sets the username/password to root.Finally assign the alias of this link to db_1.

Similarly, we can also use the `load` syntax to load the data source:

```sql
> LOAD jdbc.`db.table` OPTIONS
and driver="com.mysql.jdbc.Driver"
and url="jdbc:mysql://127.0.0.1:3306/...."
and user="..."
and password="...."
AS table1;
```

Then you can use db_1 to load any table in the database:

```
> LOAD jdbc.`db_1.table1` as table1;
> LOAD jdbc.`db_1.table2` as table2;

> SELECT * from table1 as output;
```

### Optional parameter list

| Property Name | Meaning |
|---|---|
| `url` | The JDBC URL to connect to. The source-specific connection properties may be specified in the URL. e.g., jdbc：postgresql://localhost/test?user=fred&password=secret |
| `dbtable` | The JDBC table that should be read. Note that anything that is valid in a FROM clause of a SQL query can be used. For example, instead of a full table you could also use a subquery in parentheses. |
| `driver` | The class name of the JDBC driver to use to connect to this URL. |
| `partitionColumn, lowerBound, upperBound` | These options must all be specified if any of them is specified. In addition, numPartitions must be specified. They describe how to partition the table when reading in parallel from multiple workers. partitionColumn must be a numeric column from the table in question. Notice that lowerBound and upperBound are just used to decide the partition stride, not for filtering the rows in table. So all rows in the table will be partitioned and returned. This option applies only to reading. |
| `numPartitions` | The maximum number of partitions that can be used for parallelism in table reading and writing. This also determines the maximum number of concurrent JDBC connections. If the number of partitions to write exceeds this limit, we decrease it to this limit by calling coalesce(numPartitions) before writing. |
| `fetchsize` | The JDBC fetch size, which determines how many rows to fetch per round trip. This can help performance on JDBC drivers which default to low fetch size (eg. Oracle with 10 rows). This option applies only to reading. When the data source of jdbc is mysql, It defaults to -2147483648 (1000 for previous versions of spark 3) by default, we support row-by-row data loading by default. |
| `batchsize` | The JDBC batch size, which determines how many rows to insert per round trip. This can help performance on JDBC drivers. This option applies only to writing. It defaults to 1000. |
| `isolationLevel` | The transaction isolation level, which applies to current connection. It can be one of NONE, READ_COMMITTED, READ_UNCOMMITTED, REPEATABLE_READ, or SERIALIZABLE, corresponding to standard transaction isolation levels defined by JDBC's Connection object, with default of READ_UNCOMMITTED. This option applies only to writing. Please refer the documentation in java.sql.Connection. |
| `sessionInitStatement` | After each database session is opened to the remote DB and before starting to read data, this option executes a custom SQL statement (or a PL/SQL block). Use this to implement session initialization code. Example: option("sessionInitStatement", """BEGIN execute immediate 'alter session set "_serial_direct_read"=true'; END;""") |
| `truncate` | This is a JDBC writer related option. When SaveMode.Overwrite is enabled, this option causes Spark to truncate an existing table instead of dropping and recreating it. This can be more efficient, and prevents the table metadata (e.g., indices) from being removed. However, it will not work in some cases, such as when the new data has a different schema. It defaults to false. This option applies only to writing. |
| `createTableOptions` | This is a JDBC writer related option. If specified, this option allows setting of database-specific table and partition options when creating a table (e.g., CREATE TABLE t (name string) ENGINE=InnoDB.). This option applies only to writing. |
| `createTableColumnTypes` | The database column data types to use instead of the defaults, when creating the table. Data type information should be specified in the same format as CREATE TABLE columns syntax (e.g: "name CHAR(64), comments VARCHAR(1024)"). The specified types should be valid spark sql data types. This option applies only to writing. |
| `customSchema` | The custom schema to use for reading data from JDBC connectors. For example, "id DECIMAL(38, 0), name STRING". You can also specify partial fields, and the others use the default type mapping. For example, "id DECIMAL(38, 0)". The column names should be identical to the corresponding column names of JDBC table. Users can specify the corresponding data types of Spark SQL instead of using the defaults. This option applies only to reading. |

- `partitionColumn`, `lowerBound`, `upperBound` and `numPartitions` are used to control the degree of parallelism of loading tables. You can adjust these parameters to improve the loading speed.
- When `driver` is MySQL, `url` is `useCursorFetch=true` by default and `fetchsize` is `-2147483648` by default (in spark2 `fetchsize` can not be a negative number and the default value is 1000), which is used to pull data in the way of  database cursors to avoid OOM caused by full loading.

**Byzer built-in parameters**

| Property Name | Meaning |
|---|---|
| prePtnArray | Prepartitioned array, default comma delimited |
| prePtnDelimiter | Prepartition separator |

**Pre-partitioning example**

```
> LOAD jdbc.`db.table` OPTIONS
and driver="com.mysql.jdbc.Driver"
and url="jdbc:mysql://127.0.0.1:3306/...."
and user="..."
and password="...."
and prePtnArray = "age<=10 | age > 10"
and prePtnDelimiter = "\|"
as table1;
```
### MySQL native SQL loading
Note: Byzer also supports loading data by using MySQL's native SQL. 

For example:

```sql
> LOAD jdbc.`db_1.test1` WHERE directQuery='''
select * from test1 where a = "b"
''' AS newtable;

> SELECT * FROM newtable;
```

This situation requires that the loaded dataset should not be too large.

With system authorization you can perform access control on this statement which is at the table level. If you need to control the column, you need to add the following parameters when starting:

```
--conf "spark.mlsql.enable.runtime.directQuery.auth=true"
```


## save data

After establishing connection to JDBC data, you can use the `save` statement to save data. Byzer supports using `append` or `overwrite` method to save data.

Here is an example of `append`:
```
> SAVE append tmp_article_table as jdbc.`db_1.crawler_table`;
```

> This statement indicates that we save data by appending. Add data that comes from the table `tmp_article_table` to `crawler_table` in `db_1`

If you need to save data by overwriting, please use:

```
> SAVE overwrite ....
```

If you need to create a table before writing to the table, you can use ET called JDBC. The ET essentially executes operation instructions on the Driver side.
```
> RUN command AS JDBC.`db_1._` WHERE
`driver-statement-0`="drop table test1"
and `driver-statement-1`="create table test1.....";

> SAVE append tmp_article_table AS jdbc.`db_1.test1`;
```
> In this statement, we first delete `test1`, then create `test1`, and finally use the `save` statement to save the data results.

**Note**: The path after `JDBC.`should be written as `db_1._`, which means that the table name is ignored.

## Upsert

Currently, `Upsert` operations are only supported for MySQL and the `idCol` field needs to be specified in `save`.

The role of `idCol`
- Label data with  `Upsert`
- Determine the fields that need to be updated because the primary key does not need to be updated. Byzer will remove the fields defined by `idCol` to get the field that needs to be updated.


Example:

```sql
> SAVE append tmp_article_table AS jdbc.`db_1.test1`
WHERE idCol="a,b,c";
```
> Byzer uses MySQL's `duplicate key` syntax internally. Users need to confirm whether the database table being operated is constrained by duplicate composite keys.
> If the constraint of composite keys is not defined at the database level, the `update` operation will not be performed and the data will continue to increase.


## Streaming data to MySQL

Example:

```
> SET streamName="mysql-test";

> SAVE append table_1 AS streamJDBC.`mysql1.test1`
OPTIONS mode="Complete"
and `driver-statement-0`="create table  if not exists test1(k TEXT,c BIGINT)"
and `statement-0`="insert into wow.test1(k,c) values(?,?)"
and duration="3"
and checkpointLocation="/tmp/cpl3";
```

> You can use the `streamJDBC` data source to write data to MySQL. `driver-statement-0` will only be executed once during the entire run. `statement-0` will be executed for each record.

**Note**: The order of the placeholders in the `insert` statement needs to be the same as the order of the columns in `table_1`.







