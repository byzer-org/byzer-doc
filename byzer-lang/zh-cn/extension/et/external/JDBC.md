## 直接操作MySQL

通过前面介绍的jdbc数据源，其实我们可以完成对MySQL数据的读取和写入。但是如果我们希望删除或者创建表呢？这个时候可以使用
JDBC ET。

### 如何使用

具体用法如下：

```sql
set user="root";
set password="root";

connect jdbc where
url="jdbc:mysql://127.0.0.1:3306/wow?characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&tinyInt1isBit=false"
and driver="com.mysql.jdbc.Driver"
and user="${user}"
and password="${password}"
as db_1;

run command as JDBC.`db_1._` where 
`driver-statement-0`="drop table if exists test1"
and `driver-statement-1`='''
CREATE TABLE test1
(
    id CHAR(200) PRIMARY KEY NOT NULL,
    name CHAR(200)
);''';
```

我们先用connect语法获得数据连接，然后通过JDBC transformer完成删除和创建表的工作。 driver-statement-[number]  中的number表示执行的顺序。