## 数据加载/Load

Kolo-lang 认为一切都可以加载为表，可能是某个文件，也可能是一个 Rest 接口，也可能是某数据库，
或者是数仓或者数据湖。 


### 基本使用

先来看一个最简单的 load 语句：

```sql
set abc='''
{ "x": 100, "y": 200, "z": 200 ,"dataType":"A group"}
{ "x": 120, "y": 100, "z": 260 ,"dataType":"B group"}
''';
load jsonStr.`abc` as table1;
```

在这个示例中，设置了一个变量，变量名称是 abc， 通过 jsonStr 数据源，使用 load 语句将这段文本注册成一张视图（表）。

运行结果如下：

```
dataType  x         y   z

A         group	100	200	200
B         group	120	100	260

```

仔细看该语句，第一个关键词是 load，紧接着接一个数据源或者格式名称，比如上面的例子是 `jsonStr` ，这表示加载一个json的字符串。
数据源后面接 `.` 和 `abc` 。 通常 `` 内是个路径。比如 csv.`/tmp/csvfile`。 

为了方便引用加载的结果表，我们使用 as 句式，将结果取名为 table1。

table1 可以被后续的 select 句式引用：

```sql
set abc='''
{ "x": 100, "y": 200, "z": 200 ,"dataType":"A group"}
{ "x": 120, "y": 100, "z": 260 ,"dataType":"B group"}
''';
load jsonStr.`abc` as table1;
select * from table1 as output;
```

### 获取可用数据源

通过如下指令来查看当前支持的数据源：

```sql
!show datasources;
```

用户可以通过模糊匹配来定位某个数据源是否存在：

```sql
!show datasources;
!lastCommand named datasources;
select * from datasources where name like "%csv%" as output;
```

当用户想知道数据源(如 csv )的一些参数时，可以通过如下命令查看：

```sql
!show datasources/params/csv;
```

### 直接查询模式(DirectQuery)

有部分数据源支持直接查询模式。

以 JDBC 数据源为例:

```sql
connect jdbc where
 url="jdbc:mysql://127.0.0.1:3306/wow?characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&tinyInt1isBit=false"
 and driver="com.mysql.jdbc.Driver"
 and user="xxxx"
 and password="xxxx"
 as mysql_instance;

load jdbc.`mysql_instance.test1` where directQuery='''
select * from test1 limit 10
''' as newtable;

select * from newtable as output;
```

在 JDBC 数据源的 where/options 参数里，用户可以配置一个 directQuery 参数。
该参数可以写数据源原生支持的语法。比如对于 MongoDB 可能就是一段 JSON, 而对于
MySQL 则可能是合乎 MySQL 语法的 SQL。

Kolo-lang 会将 directQuery 的查询下推到底层引擎，并且将执行的结果作为注册成新的表。 
在上面的例子中，新表名称为 newtable. 这个表可以被后续的 Kolo-lang 代码引用。