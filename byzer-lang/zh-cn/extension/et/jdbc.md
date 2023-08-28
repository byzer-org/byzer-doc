# byzer-execute-sql JDBC 插件

JDBC 插件是一个基于JDBC的插件，可以通过JDBC连接各种传统关系型数据库比如 Oracle/DB2/MySQL等，也可以
支持大数据体系下的MPP数据库，执行SQL语句，把数据转化为Byzer内存表。

用户需要确保对应的驱动已经安装到了 Byzer 的 plugin 或者 lib 目录下。

## 插件信息

1. 插件: https://download.byzer.org/byzer-extensions/nightly-build/byzer-execute-sql-3.3_2.12-0.1.0-SNAPSHOT.jar
2. 插件入口类：tech.mlsql.plugins.execsql.ExecSQLApp
3. 插件名称： byzer-execute-sql-3.3

可以参考在线/离线安装文档进行安装。

## 使用方式

下面是基本使用方式：

### 创建一个MySQL 数据库连接：

```sql
!conn business 
"url=jdbc:mysql://127.0.0.1:3306/business?characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&tinyInt1isBit=false&useSSL=false" 
"driver=com.mysql.jdbc.Driver" 
"user=root" 
"password=xxxx";
```

第一个参数是数据库连接名称，后面的参数都是连接必须的配置选项。

### 断开一个 MySQL 数据库链接：

```sql
!conn remove business;
```

在 MySQL中执行诸如创建临时表等操作(这里)

```sql
!exec_sql '''

create table1 from select content as instruction,"" as input,summary as output 
from tunningData

''' by business;
```

指定连接执行SQL，主要是一些创建MPP虚拟表的操作。如果没有异常，不会有返回。

把 MySQL 的数据转化为 Byzer 内存表 tunningData 使用：

```sql

!exec_sql tunningData  from '''

select content as instruction,"" as input,summary as output 
from tunningData

''' by business;

select * from tunningData as output;
```

注意，这里是内存表，数据都会保存在内存里。所以数据规模不能太大，最好加上limit限制。