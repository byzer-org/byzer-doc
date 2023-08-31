# JDBC 插件(内置)

为了方便用户直接操作数据库，执行 Query/DDL 语句，Byzer 内置了一个插件。

## DDL 模式

```sql
run command as JDBC.`` where
sqlMode="ddl"
and driver="com.mysql.jdbc.Driver"
and url="jdbc:mysql://127.0.0.1:3306/wow?useSSL=false&haracterEncoding=utf8&zeroDateTimeBehavior=convertToNull&tinyInt1isBit=false"
and user="root"
and password="xxxxx"
and `driver-statement-0`='''
create table xxxx
(
    id int,
    name string
)
''';
```

其中，`driver-statement-<序号>` 是一个 DDL 语句。 你可以填写多个,比如，`driver-statement-0`,`driver-statement-1` 等。
系统会按照最后的序号执行。

## Query模式

```sql
run command as JDBC.`` where
sqlMode="query"
and driver="com.mysql.jdbc.Driver"
and url="jdbc:mysql://127.0.0.1:3306/wow?useSSL=false&haracterEncoding=utf8&zeroDateTimeBehavior=convertToNull&tinyInt1isBit=false"
and user="root"
and password="xxxxx"
and `driver-statement-query`='''
select * from xxxx
'''
as newTable;

select * from newTable as output;
```

注意，这里的 `driver-statement-query` 是一个 Query 语句，而不是 DDL 语句，名字也和 DDL 模式下有所区别。


