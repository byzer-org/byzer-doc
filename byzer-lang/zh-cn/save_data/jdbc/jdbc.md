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

上述介绍的方式是直接通过 Save 语法在数据库中创建表

如果需要先创建表，再写入表，可以使用名为 JDBC 的 ET。该 ET 本质上是在 Driver 端执行操作指令。
```
> RUN command AS JDBC.`db_1._` WHERE
`driver-statement-0`="drop table test1"
and `driver-statement-1`="create table test1.....";

> SAVE append tmp_article_table AS jdbc.`db_1.test1`;
```
> 这段语句，我们先删除 test1 ,然后创建 test1 ,最后使用 `save` 语句把进行数据结果的保存。

**注意**： `JDBC.`后面的路径要写成 `db_1._`,表示忽略表名。



### Upsert 语义支持

MySQL 支持数据的 `Upsert` 操作，只需要在 `save` 时指定 `idCol` 字段即可。

`idCol` 的作用
- 标记数据需要执行 `Upsert` 操作 
- 确定需要的更新字段，因为主键本身是不需要更新的。Byzer 会将表所有的字段去除
`idCol` 定义的字段，得到需要更新的字段。


下面是一个简单的例子：

```sql
> SAVE append tmp_article_table AS jdbc.`db_1.test1`
WHERE idCol="a,b,c";
```
>Byzer 内部使用了 MySQL 的 `duplicate key` 语法，用户需要确认操作的数据库表确实有重复联合主键约束。
>如果数据库层面没有定义联合约束主键，将不会执行 `update` 操作，数据会不断增加。



### 5. 流式数据写入 MySQL

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

