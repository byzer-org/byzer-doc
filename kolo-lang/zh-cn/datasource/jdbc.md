# JDBC 数据源

Kolo 支持加载符合 JDBC 协议的数据源，如 MySQL, Oracle,Hive thrift server等。

本节会以 MySQL 为主要例子进行介绍。

## 加载数据

Kolo 支持通过 `connect` 语法，以及 `load` 语法建立与 JDBC 数据源的连接。需要注意的是，建立的连接是 APP 范围內生效的。

下面是一个使用 `connect` 语法的例子：

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

> 这条语句表明，Kolo 连接的是 JDBC 数据源。WHERE 语句中包含连接相关的参数，指定驱动是 MySQL 的驱动，设置用户名/密码为 root。
最后将这个链接的别名设置为 db_1.

同样，我们也可以使用 `load` 语法加载数据源：

```sql
> LOAD jdbc.`db.table` OPTIONS
and driver="com.mysql.jdbc.Driver"
and url="jdbc:mysql://127.0.0.1:3306/...."
and user="..."
and password="...."
AS table1;
```

在这之后，可以使用 db_1 加载数据库中的任意表：

```
> LOAD jdbc.`db_1.table1` as table1;
> LOAD jdbc.`db_1.table2` as table2;

> SELECT * from table1 as output;
```

### 可选参数列表

| Property Name  |  Meaning |
|---|---|
|url|The JDBC URL to connect to. The source-specific connection properties may be specified in the URL. e.g., jdbc：postgresql://localhost/test?user=fred&password=secret|
|dbtable |The JDBC table that should be read. Note that anything that is valid in a FROM clause of a SQL query can be used. For example, instead of a full table you could also use a subquery in parentheses.|
|driver |The class name of the JDBC driver to use to connect to this URL.|
|partitionColumn, lowerBound, upperBound|	These options must all be specified if any of them is specified. In addition, numPartitions must be specified. They describe how to partition the table when reading in parallel from multiple workers. partitionColumn must be a numeric column from the table in question. Notice that lowerBound and upperBound are just used to decide the partition stride, not for filtering the rows in table. So all rows in the table will be partitioned and returned. This option applies only to reading.|
|numPartitions|	The maximum number of partitions that can be used for parallelism in table reading and writing. This also determines the maximum number of concurrent JDBC connections. If the number of partitions to write exceeds this limit, we decrease it to this limit by calling coalesce(numPartitions) before writing.|
|fetchsize|	The JDBC fetch size, which determines how many rows to fetch per round trip. This can help performance on JDBC drivers which default to low fetch size (eg. Oracle with 10 rows). This option applies only to reading. When the data source of jdbc is mysql, It defaults to -2147483648 (1000 for previous versions of spark 3) by default, we support row-by-row data loading by default.|
|batchsize|	The JDBC batch size, which determines how many rows to insert per round trip. This can help performance on JDBC drivers. This option applies only to writing. It defaults to 1000.|
|isolationLevel|	The transaction isolation level, which applies to current connection. It can be one of NONE, READ_COMMITTED, READ_UNCOMMITTED, REPEATABLE_READ, or SERIALIZABLE, corresponding to standard transaction isolation levels defined by JDBC's Connection object, with default of READ_UNCOMMITTED. This option applies only to writing. Please refer the documentation in java.sql.Connection.|
|sessionInitStatement|	After each database session is opened to the remote DB and before starting to read data, this option executes a custom SQL statement (or a PL/SQL block). Use this to implement session initialization code. Example: option("sessionInitStatement", """BEGIN execute immediate 'alter session set "_serial_direct_read"=true'; END;""")|
|truncate|	This is a JDBC writer related option. When SaveMode.Overwrite is enabled, this option causes Spark to truncate an existing table instead of dropping and recreating it. This can be more efficient, and prevents the table metadata (e.g., indices) from being removed. However, it will not work in some cases, such as when the new data has a different schema. It defaults to false. This option applies only to writing.|
|createTableOptions|	This is a JDBC writer related option. If specified, this option allows setting of database-specific table and partition options when creating a table (e.g., CREATE TABLE t (name string) ENGINE=InnoDB.). This option applies only to writing.|
|createTableColumnTypes|	The database column data types to use instead of the defaults, when creating the table. Data type information should be specified in the same format as CREATE TABLE columns syntax (e.g: "name CHAR(64), comments VARCHAR(1024)"). The specified types should be valid spark sql data types. This option applies only to writing.|
|customSchema|	The custom schema to use for reading data from JDBC connectors. For example, "id DECIMAL(38, 0), name STRING". You can also specify partial fields, and the others use the default type mapping. For example, "id DECIMAL(38, 0)". The column names should be identical to the corresponding column names of JDBC table. Users can specify the corresponding data types of Spark SQL instead of using the defaults. This option applies only to reading.|

其中
- `partitionColumn`, `lowerBound`, `upperBound`,`numPartitions` 用来控制加载表的并行度。你可以调整这几个参数提升加载速度。
- 当 `driver` 为 MySQL 时，`url` 默认设置参数 useCursorFetch=true，并且 `fetchsize` 默认为-2147483648（在 spark2 中不支持设置 `fetchsize` 为负数，默认值为1000），用于支持数据库游标的方式拉取数据，避免全量加载导致 OOM。

**Kolo内置参数**

| Property Name  |  Meaning |
|---|---|
|prePtnArray|Prepartitioned array, default comma delimited|
|prePtnDelimiter|Prepartition separator|

**预分区使用样例**

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
### MySQL 原生 SQL 加载
值得注意的是，Kolo 还支持使用 MySQL 原生 SQL 的方式加载数据。比如：

```sql
> LOAD jdbc.`db_1.test1` WHERE directQuery='''
select * from test1 where a = "b"
''' AS newtable;

> SELECT * FROM newtable;
```

这种情况要求加载的数据集不能太大。 

如果你希望对这个语句也进行权限控制，如果是到表级别，那么只要系统开启授权即可。
如果是需要控制到列，那么启动时需要添加如下参数：

```
--conf "spark.mlsql.enable.runtime.directQuery.auth=true" 
```


## 保存数据

建立 JDBC 数据连接后，你可以使用 `save` 语句对得到的数据进行保存。Kolo 支持 `append`/`overwrite` 方式保存数据。

下面是 `append` 的例子：
```
> SAVE append tmp_article_table as jdbc.`db_1.crawler_table`;
```

> 这条语句表明，我们使用追加的方式进行保存。向 db_1中的 crawler_table 里添加数据，这些数据来源于表
 tmp_article_table

如果需要使用覆盖的方式保存，请使用：

```
> SAVE overwrite ....
```

如果需要先创建表，再写入表，可以使用名为 JDBC 的 ET。该 ET 本质上是在 Driver 端执行操作指令。
```
> RUN command AS JDBC.`db_1._` WHERE
`driver-statement-0`="drop table test1"
and `driver-statement-1`="create table test1.....";

> SAVE append tmp_article_table AS jdbc.`db_1.test1`;
```
> 这段语句，我们先删除 test1 ,然后创建 test1 ,最后使用 `save` 语句把进行数据结果的保存。

**注意**： `JDBC.`后面的路径要写成 `db_1._`,表示忽略表名。

## Upsert

目前只支持对 MySQL 执行 `Upsert` 操作，只需要在 `save` 时指定 `idCol` 字段即可。

`idCol` 的作用
- 标记数据需要执行 `Upsert` 操作 
- 确定需要的更新字段，因为主键本身是不需要更新的。Kolo 会将表所有的字段去除
`idCol` 定义的字段，得到需要更新的字段。


下面是一个简单的例子：

```sql
> SAVE append tmp_article_table AS jdbc.`db_1.test1`
WHERE idCol="a,b,c";
```
>Kolo 内部使用了 MySQL 的 `duplicate key` 语法，用户需要确认操作的数据库表确实有重复联合主键约束。
>如果数据库层面没有定义联合约束主键，将不会执行 `update` 操作，数据会不断增加。


## 流式数据写入 MySQL

举个简单的例子：

```
> SET streamName="mysql-test";

> SAVE append table_1 AS streamJDBC.`mysql1.test1` 
OPTIONS mode="Complete"
and `driver-statement-0`="create table  if not exists test1(k TEXT,c BIGINT)"
and `statement-0`="insert into wow.test1(k,c) values(?,?)"
and duration="3"
and checkpointLocation="/tmp/cpl3";
```

> 我们使用 `streamJDBC` 数据源可以完成将数据写入到MySQL中。`driver-statement-0` 在整个运行期间只会执行一次。`statement-0`
则会针对每条记录执行。

**注意**：`insert` 语句中的占位符顺序需要和 table_1 中的列顺序保持一致。






