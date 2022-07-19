# 写入 JDBC

在 [JDBC 数据源](/byzer-lang/zh-cn/datasource/jdbc/jdbc.md) 中我们介绍了如何建立 JDBC 的连接，和如何从 JDBC 中取数，那接下来我们介绍当处理完数据后，如何将表写入至 JDBC 数据源

### 写入数据至 JDBC


建立 JDBC 数据连接后，你可以直接使用 `SAVE` 语法对得到的数据进行保存，在 JDBC 中直接保存成表，保存的方式有两种：`append` 增量保存以及 `overwrite` 全表覆盖保存

#### Append 写入 


下面是 `append` 保存数据至 MySQL 的例子，通过和 MySQL 建立 JDBC 连接之后，加载一个 CSV 文件，将其进行根据条件进行筛选过滤的操作，然后将其以 append 的方式写入至 MySQL 中 `byzer_demo` 数据库中的 `testtbl` 的表。写入数据至 MySQL 的时候 Byzer 会自动根据 `final_table` 的 schema 在 MySQL 中创建该表，创建的表名为 `testtbl`，位于 `byzer_demo` 数据库下，**数据是以追加的方式写入至该表，当追加的表的 schema 和数据源中的表 schema 不一致时，保存会报错**。

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

> LOAD csv.`/tmp/upload/ConsumerComplaints.csv` 
where header="true" and inferSchema="true" as csvTable;

> SELECT * from csvTable where Company="Bank of America" as final_table;

> SAVE append final_table as jdbc.`mysql_instance.testtbl`;
```


#### Overrite 覆盖写入

还是以上述例子为例，当加载了 CSV 作为表并做了转换之后，我们以覆盖写入的方式将数据写入至 MySQL 中，注意**覆盖写入的时候会覆盖掉该表的 Schema 以及数据**。

```sql
...
> SAVE final_table as jdbc.`mysql_instance.testtbl`;
```

### 通过 JDBC ET 创建表

如果您希望通过 Byzer 引擎提供的 JDBC ET 扩展，来直接执行 JDBC 原生的 DDL 语句来进行表的创建，可以参考 [JDBC 数据源](/byzer-lang/zh-cn/datasource/jdbc/jdbc.md) 章节中的 **如何对 JDBC 中执行数据源原生语句** 一节


### Upsert 语义支持

有些数据库是可以支持 Upsert 语义操作的，关于什么是 Upsert 可以参考 [Upsert in SQL: What is an Upsert, and When Should You Use One?](https://www.cockroachlabs.com/blog/sql-upsert/) 一文的解释。目前 Byzer 支持 `MySQL` 或 `Oracle` 的 Upsert 语义。 

接下来我们以 MySQL 来举例，MySQL 支持数据的 `Upsert` 操作，在 Byzer 语句中只需要在 `SAVE` 语句中指定 `idCol` 字段是表的哪个字段即可，如下述代码示例：

```sql
> SAVE append tmp_data AS jdbc.`db_1.test1`
WHERE idCol="a,b,c";
```
在该代码示例中，我们要以 `append` 增量保存的方式，将表 `tmp_data` 以 Upsert 的方式写入至 `db_1.test1` 中 

其中 `idCol` 参数的作用
- 标记该表写入时，数据是需要执行 `Upsert` 操作 
- 确定需要的更新字段，因为主键本身是不需要更新的，真正更新的是该主键所在行（row）的其他列（column）的值

> 注意：
> 如果数据库层面没有定义联合约束主键，将不会执行 `update` 操作，数据会不断增加。
> Upsert 执行时要求表的 Schema 是对齐的，否则更新失败

实现 Upsert 语义的原理：
- MySQL：使用了 MySQL 的 `duplicate key` 机制，用户需要确认操作的数据库表确实有重复联合主键约束
- Oracle: 使用了 Oracle 的 `merge into` 机制， 详情可见 [BIP 2: Support upserting oracle table](https://github.com/byzer-org/byzer-lang/wiki/BIP-2:-Support-upserting-oracle-table)




### 流式数据写入 JDBC

Byzer 也可以通过 `steamJDBC` 来实现流式写入的方式，将数据流式写入 JDBC。


下述示例是一个通过流式写入 MySQL 的示例：

```sql
> SET streamName="mysql-test";

> SAVE append table_1 AS streamJDBC.`mysql_instance.test1` 
OPTIONS mode="Complete"
and `driver-statement-0`="create table  if not exists test1(k TEXT,c BIGINT)"
and `statement-0`="insert into wow.test1(k,c) values(?,?)"
and duration="3"
and checkpointLocation="/tmp/cpl3";
```

我们使用 `streamJDBC` 可以完成将数据写入到 MySQL 中。其中
- `driver-statement-0` 在整个运行期间只会执行一次
- `statement-0` 则会针对每条记录执行

**注意**：`insert` 语句中的占位符顺序需要和 table_1 中的列顺序保持一致。

