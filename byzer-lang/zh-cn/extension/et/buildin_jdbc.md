# JDBC 插件(内置)

为了方便用户直接操作数据库，执行 DDL 语句，Byzer 内置了一个插件。

## 使用方式

```sql
run command as SQLJDBC.`` where
driver="com.mysql.jdbc.Driver"
and url="jdbc:mysql://127.0.0.1:3306/wow?useSSL=false&haracterEncoding=utf8&zeroDateTimeBehavior=convertToNull&tinyInt1isBit=false"
and user="root"
and password="xxxxx"
and `driver-statement-0`='''

''';
```

其中，`driver-statement-<序号>` 是一个 DDL 语句。 你可以填写多个,比如，`driver-statement-0`,`driver-statement-1` 等。
系统会按照最后的序号执行。

