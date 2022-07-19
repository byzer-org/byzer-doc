# JDBC 数据源

Byzer 支持加载符合 JDBC 协议的数据源，如 MySQL, Oracle,Hive thrift server 等，或者其他提供了标准 JDBC 协议驱动的任何系统。

Byzer 加载 JDBC 类数据源后，会通过两步来进行，先通过 JDBC URL 连接信息连接数据源的数据库，然后可以加载库中的表，此时就可以通过 Byzer SQL 来进行加载表的查询。

> 注意:
> 1. 通过 JDBC 协议来进行表加载的时候，和数据库真实发生连接的时候是在 Executor 去执行加载语句的时候发生的，当一次 Byzer 语句的执行请求执行完毕后，连接释放
> 2. 加载的过程实际上是将 SQL 语句的 Filter 算子下推至数据源侧，将数据按批拉取到 Byzer 引擎 executor 端的内存中进行计算，这个过程是被引擎的 Executor 端进行并行的，用户可以通过调整参数来进行
> 3. 如果高频次或大数据量的数据拉取，会对数据源侧造成较大的负担。当数据量较大时推荐的方式为，将 JDBC 数据源一次性拉取到 Byzer 所在的文件系统进行存储，然后在基于文件系统上的文件进行后续的处理


### 1. 连接/加载 JDBC 数据源

我们以 MySQL 5.7 数据库为例， MySQL 中有如下的库表

|DB| Table|
|--|--|
|byzer_demo|jdbc_demo|
|byzer_demo|tutorials_tbl|

#### 准备 JDBC 驱动
在连接 JDBC 数据源之前，我们需要先准备数据源的 JDBC 驱动，将其放入 Byzer Engine 安装路径中的 `${BYZER_HOME}/libs` 目录下。然后需要通过 `${BYZER_HOME}/bin/byzer.sh restart` 命令来重启 Byzer 引擎服务。

> 注意： Byzer Engine 的产品包中已经**内置了 MySQL 5.x 以及 Apache Kylin 的 JDBC Driver**，无需做额外的配置工作

####  通过 CONNECT 语法和 LOAD 语法加载 JDBC （Optional）

连接 JDBC 数据源的操作实际上是由 `Load` 语法语句来完成的，但考虑以下两个原因：
- 每次加载 JDBC 表时，需要在每条 Load 语句的条件中写入连接信息，非常繁琐
- 不是每个人都能够轻易的得到数据库的完整连接信息

所以 Byzer 提供了 `CONNECT` 语法来进行连接信息的保存。下面是一个保存连接到 MySQL 中 wow database 的例子：


```sql
> SET user="root";
> SET password="root";
> SET jdbc_url="jdbc:mysql://127.0.0.1:3306/byzer_demo?characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&tinyInt1isBit=false&useSSL=false";
> CONNECT jdbc WHERE
 url="${jdbc_url}"
 and driver="com.mysql.jdbc.Driver"
 and user="${user}"
 and password="${password}"
 AS mysql_instance;
```

这样我们就定义了一个 MySQL 数据库的连接信息并命名为 `mysql_instance`，在引擎中，`mysql_instance` 不同于其他语法定义的临时表变量，是用户 Session 级别或 Request 级别，而 `CONNECT` 定义的连接信息变量是**引擎全局级别**的，也就是说，上述代码一旦被执行，那么 `mysql_instance` 这个变量就被以静态变量的方式存在引擎的内存当中。

> 注意：
> 1. 由于 connection 定义的连接信息变量是全局的，所以是有可能被任一在该引擎上执行的其他 connection 语句进行覆盖的，这点一定要小心
> 2. `mysql_instance` 是无法被 `SELECT` 语法进行查询的
> 3. 引擎的默认实现中，是没有进行表的权限校验的，管理员如果有需要对不同用户进行表连接和访问的需求时，可以通过实现权限接口的插件来完成，实现的代码类可参考 [DefaultConsoleClient.scala](https://github.com/byzer-org/byzer-lang/blob/master/streamingpro-core/src/main/java/streaming/dsl/auth/client/DefaultConsoleClient.scala)


当我们定义了 MySQL 的连接信息后，可以通过 `Load` 语句和 `jdbc`来完成表的加载和使用

```sql
> LOAD jdbc.`mysql_instance.jdbc_demo` as jdbc_demo_tbl;
> LOAD jdbc.`mysql_instance.tutorials_tbl` as tutorials_tbl;

> SELECT * from jdbc_demo_tbl as output;
```

这样我们就完成了一个通过 `CONNECT` 语法和 `LOAD` 语法完成 MySQL 的连接，并将数据库中的表进行了加载和操作。


#### 通过 Load 语法直接加载

除了可以通过 `CONNECT` 语法来建立连接，我们也可以通过 `LOAD` 语法来直接建立连接和加载 JDBC 中的库表，效果和使用  `CONNECT` + `LOAD` 语法等同，我们来看下面这个例子：


```sql
> SET user="root";
> SET password="root";
> SET jdbc_url="jdbc:mysql://127.0.0.1:3306/byzer_demo?characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&tinyInt1isBit=false&useSSL=false";

> LOAD jdbc.`byzer_demo.tutorials_tbl` 
where driver="com.mysql.jdbc.Driver"
and url="${jdbc_url}"
and user="${user}"
and password="${password}"
AS tutorial_tbl;

> SELECT * from tutorial_tbl as output;
```
这与我们就通过 `LOAD` 语句单独完成了 MySQL 中表的加载

#### 加载 JDBC 过程中可选参数列表

参数由两类组成：
- Spark 引擎端参数
- Byzer 内置的参数

##### Spark 参数
Byzer 连接 JDBC 的底层实现是通过 Spark JDBC 来实现的，所以在使用的过程中，我们可以通过在 `WHERE` 语句中调整参数来达到类似控制并行度的问题。 参数文档可参考 Spark 的官方文档 [JDBC To Other Databases](https://spark.apache.org/docs/3.1.1/sql-data-sources-jdbc.html)

| 参数名称 |  解释 |
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
- 当 `driver` 为 MySQL 时，`url` 默认设置参数 `useCursorFetch=true`，并且 `fetchsize` 默认为`-2147483648`（在 spark2 中不支持设置 `fetchsize` 为负数，默认值为 `1000`），用于支持数据库游标的方式拉取数据，避免全量加载导致 OOM。

#### Byzer 内置参数



| 参数名称 |  解释 |
|---|---|
|prePtnArray|预分区数组，默认使用逗号分割|
|prePtnDelimiter|预分区参数分隔符|

下面是一个使用预分区的示例

```sql
> LOAD jdbc.`db.table` WHERE
and driver="com.mysql.jdbc.Driver"
and url="jdbc:mysql://127.0.0.1:3306/...."
and user="..."
and password="...."
and prePtnArray = "age>=10 | age < 30"
and prePtnDelimiter = "\|"
as table1;
```


#### Direct Query - 使用原生 SQL 加载 JDBC 数据

Byzer 除了上述通过 `CONNECT` 语法和 `LOAD` 语法来加载 JDBC 数据的方式外，还可以支持使用 JDBC 数据源的原生 SQL 的方式加载数据，以下面的示例为例，我们可以允许用户在 `WHERE` 语句中通过 `directQuery` 参数可以将 JDBC 系统支持的原生的 SQL 来进行数据加载的操作。


```sql
> LOAD jdbc.`db_1.test1` 
  WHERE directQuery='''
  select * from test1 where a = "b"
  ''' 
  AS newtable;

> SELECT * FROM newtable AS output;
```

**注意**：
1. 区别于 `CONNECT` 和 `LOAD`, Direct Query 模式是单线程的方式从数据库进行加载的
2. DirectQuery 模式和 `CONNECT` 语法混用时, 在 CONNECT 语句定义的连接信息和库名同名时，有可能会发生表的引用关系混乱的情况，建议 directlyQuery 只在 `LOAD` 语句连接 JDBC 数据源中进行使用 
3. DirectQuery 模式默认只执行以 `select` 开头的语句，没有做其他的校验，如 directQuery 的语句加载的表是否和 `LOAD` 语句中声明的表做匹配校验；如果您想开启此校验功能，则需要在 `${BYZER_HOME}/conf/byzer.properties.override` 配置文件中将如下参数设置为 `true`：

```properties
spark.mlsql.enable.runtime.directQuery.auth=true 
```



### 2. 如何对 JDBC 中执行数据源原生语句

Byzer 内置提供了一个 JDBC 的 ET 实现，可以允许用户执行 DDL 语句，此功能需要 JDBC 数据源的 JDBC Driver 提供相应的 DDL 能力。注意通过该 ET 的方式执行的语句，实际上都发生在 Byzer 引擎的 Driver 端，所以请避免通过该方式进行大量的数据操作。


#### 执行 DDL 语句

我们看一个示例，当前 MySQL 中数据库包含 `jdbc_demo`， `tutorials_tbl` 两张表，我们想要在数据库中创建另外一张表 `test1`，那么我们可以通过下述语句来完成 `test1` 表的创建 


```sql
> run command as JDBC.`byzer_demo._` where 
driver="com.mysql.jdbc.Driver"
and url="${jdbc_url}"
and user="${user}"
and password="${password}"
and `driver-statement-0`="drop table if exists test1"
and `driver-statement-1`='''
CREATE TABLE test1
(
    id CHAR(200) PRIMARY KEY NOT NULL,
    name CHAR(200)
);''';
```

在该示例中，我们通过 JDBC ET 执行了一条 `Drop` 语句和 `CREATE` 语句, 其中：

- JDBC.`byzer_demo._` 指代连接 byzer_demo 这个库，但不加载某张指定的表
- `driver-statement-[number]` 中的 `number` 表示执行的顺序，从 `0` 开始计数。执行完毕后，MySQL 中可以查询到 `test1` 这张表



#### Show Databases 

如果想要在 Byzer 中执行 MySQL 中的 `show databases;` 命令来展示出当前的数据源中的数据库，我们可以通过如下的方式来完成：

```sql
> SET user="root";
> SET password="root";
> SET jdbc_url="jdbc:mysql://127.0.0.1:3306/byzer_demo?characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&tinyInt1isBit=false&useSSL=false";
> CONNECT jdbc WHERE
 url="${jdbc_url}"
 and driver="com.mysql.jdbc.Driver"
 and user="${user}"
 and password="${password}"
 AS mysql_instance;
 
 
> RUN command AS JDBC.`mysql_instance._` WHERE
sqlMode="query"
and `driver-statement-query`="show databases;"
AS output;
```

在该示例中，我们定义了 MySQL 的连接，然后通过 JDBC ET 来进行 `show databases` 的操作；由于 `show databases` 不属于 DDL 语句，我们需要在这里指定 `sqlMode` 为 `query`, 然后通过 `driver-statement-query` 来进行执行。需要注意的是，
- 在一次执行过程中，只能执行一次 `driver-statement-query` 定义的语句，如果在 where 条件中出现多个`driver-statement-query`，则会执行最后一条语句进行返回
- 针对其他数据库进行 `show database` 操作，只需按对应的语法写 query 语句即可

#### Show Tables

如同 `show database` 操作，可以根据如下示例来进行 `show tables` 的操作

```sql
> RUN command AS JDBC.`mysql_instance._` WHERE
sqlMode="query"
and `driver-statement-query`="show tables;"
AS output;
```

#### Desc Table

如同 `show database` 操作，可以根据如下示例进行 `desc table` 的操作

```sql
> SET tableName="jdbc_demo";
> RUN command AS JDBC.`mysql_instance._` WHERE
sqlMode="query"
and `driver-statement-query`="desc ${tableName};"
AS output;
```

### FAQ

#### 如何在连接 JDBC 时对密码进行加密操作？

由于在连接 JDBC 数据源时，会涉及很多敏感信息，比如 JDBC 连接串以及用户名密码等，这些信息是不建议被直接明文写在我们的脚本里的，Byzer 提供了 `aes_encry($variable)` 以及 `aes_decrypt($encrypted_variable)` 函数，来进行加密和解密的操作。我们来看下面的示例


```sql
-- 加密一个敏感变量
> select 
aes_encrypt("byzer") as password ,
aes_encrypt("jdbc:mysql://127.0.0.1:3306/wow?characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&tinyInt1isBit=false") as url 
as output;
```

在该语句中，我们对 password 和 jdbc url 进行了 aes 加密， 执行该语句，你会获得加密后的输出如下

|password|url|
|--|--|
|zAiGTbg5YQMElMlT9WYQJw==|xBWeS/BfE3t+8/h30VwpG8j6igrgeYbkMRWC7MEIMhBhwy7l6C3YIBzSokSt5b3gMX5XSPtaHAfo1tOkIMDBghXg7Ji11oXedaR+1+2FkxGS2m4MyV7CbppMAKNGi8Q/irf02bgynCtNXw2Re+fCKA==|

这样在后续的使用中，我们可以在 Byzer 语句中使用上述加密的字符串来替代明文，如下示例

```sql
> set PASSWORD=`select aes_decrypt("zAiGTbg5YQMElMlT9WYQJw==")` where type="sql" and scope="session";
> set URL=`select aes_decrypt("xBWeS/BfE3t+8/h30VwpG8j6igrgeYbkMRWC7MEIMhBhwy7l6C3YIBzSokSt5b3gMX5XSPtaHAfo1tOkIMDBghXg7Ji11oXedaR+1+2FkxGS2m4MyV7CbppMAKNGi8Q/irf02bgynCtNXw2Re+fCKA==")` where type="sql"  and scope="session";

> connect jdbc where
 url="${URL}"
 and driver="com.mysql.jdbc.Driver"
 and user="root"
 and password="${PASSWORD}"
 as mysql_instance;
```

通过这种方式，我们就避免了明文的敏感信息出现在 Byzer 的脚本中。

#### 对 JDBC 库名 (Database Name) 有什么要求？

建议 JDBC 底层数据数在命名规则上以”字母、数字和下划线“的组合为主，避免出现连字符等特殊字符

#### 连接 MySQL 时出现 Commuication Failure 的报错怎么处理？

不同的 JDK 版本中对 JDBC 连接中 SSL 连接处理有差别。比如使用 OpenJDK `1.8.0_262` 版本启动的 Byzer 引擎，如果 JDBC URL 没有声明 `useSSL=false`，是可以正常连接的，但在 OpenJDK `1.8.0_332` 版本中，就必须要在 JDBC URL 中加入 `useSSL=false` 才能正常建立连接，否则会导致连接失败。

#### Load 会把数据都加载到 Byzer 引擎的内存里么？
不会。引擎会将执行计划提交到 executor 中，executor 会批量的从 JDCB 数据源中拉取数据进行计算，同一时刻，只有一部分数据在引擎内存里。

#### Load 的时候可以加载过滤条件么
可以，用户可以在 `where` 语句中加入 filter 条件来达到数据加载时，将条件下推至 JDBC 数据源端，避免在执行过程中产生大量的数据传输。
当然如果在一次执行中， `LOAD` 语句和 `SELECT` 语句在一起执行时，用户也可以把 where 条件直接写在的 `select` 语句中，在真正执行时，下推条件也会被同时优化到 `LOAD` 语句中，效果和在 `LOAD` 语句中加入 filter 条件相同

#### Count 非常慢，怎么办？
比如用户执行如下语句想查看下表的数据条数,如果表比较大，可能会非常慢，甚至有可能导致 Engine 有节点挂掉。

```sql
> load jdbc.`db_1.tblname` as tblname;
> select count(*) from tblname as newtbl;
```

原因是引擎需要拉取全量数据（批量拉取，并不是全部加载到内存），然后计数，而且默认是单线程，一般数据库对全表扫描都比较慢，所以没有 where 条件的 count 可能会非常慢。

如果用户仅仅是为了看下表的大小，推荐用 directQuery 模式，directQuery 会把查询直接发给数据库执行，然后把得到的计算结果返回给引擎,所以非常快。 具体操作方式如下：

```sql
> load jdbc.`db_1.tblname`
 where directQuery='''
    select count(*) from tblname
''' 
as newtbl;
```

**一般我们会建议从 JDBC 过来的数据需要进行在 Delta Lake 或对象存储中进行一次落盘，这样后续在执行聚合类算子时能够充分的利用分布式的优势来提高对应的性能**

#### 在 select 语句中加了 where 条件也很慢，甚至导致引擎挂掉
有时候如果即使加了 where 条件，效果也没有达到预期的情况下，我们可以通过在 where 语句中进行调整如下参数的方式来进行执行的优化。

核心参数有如下：
1. `partitionColumn` 按哪个列进行分区
2. `lowerBound`, `upperBound`, 分区字段的最小值，最大值（可以使用 `directQuery` 获取）
3. `numPartitions` 分区数目。一般 8 个线程比较合适

注意，能够进行分区的字段要求是数字类型，推荐使用自增 id 字段。
通过这样的方式，我们能够尽可能利用引擎的分布式能力，将拉取数据的并行度提到一个相对比较合适的程度来进行加速




