# 数据加载/Load

Byzer-Lang 的 [设计理念](/byzer-lang/zh-cn/introduction/byzer_lang_design) 是 `Everything is a table`，在 Byzer-Lang 中所有的文件都可以被抽象成表的概念。

多样的数据源例如：数据库，数据仓库，数据湖甚至是 Rest API 都可以被 Byzer-lang 抽象成二维表的方式读入并进行后续的分析处理，而读入数据源的这一重要过程主要通过 `load` 句式来达成。



### 1. 基本语法

先来看一个最简单的 load 语句：

```sql
set abc='''
{ "x": 100, "y": 200, "z": 200 ,"dataType":"A group"}
{ "x": 120, "y": 100, "z": 260 ,"dataType":"B group"}
''';
load jsonStr.`abc` as table1;
```

在这个示例中，设置了一个变量，变量名称是 `abc`， 通过 `jsonStr` 数据源，使用 `load` 语句将这段文本注册成一张视图（表）。

运行结果如下：

<p align="center">
    <img src="/byzer-lang/zh-cn/grammar/image/load1.png" alt="name"  width="800"/>
</p>


**我们来解析一下该句中的语法含义和需要注意的关键点：**

```sql
load jsonStr.`abc` as table1;
```

- 第一个关键点是 `load`，代表读入数据源的行为
- 第二个关键点是 `jsonStr` ，这里代表的是数据源或者格式名称，该句表示这里加载的是一个 json 的字符串，
- 第三个关键点是 `.` 和 `abc` ， 通常反引号内是个路径，比如:

```
csv.`/tmp/csvfile`
```

- 第四个关键点：为了方便引用加载的结果表，我们需要使用 `as` 句式，将结果存为一张新表，这里我们取名为 `table1`。`table1` 可以被后续的 `select` 句式引用，例如：

```sql
set abc='''
{ "x": 100, "y": 200, "z": 200 ,"dataType":"A group"}
{ "x": 120, "y": 100, "z": 260 ,"dataType":"B group"}
''';
load jsonStr.`abc` as table1;
select * from table1 as output;
```



### 2. 如何获取可用数据源

1）既然 `load` 句式是用来获取数据源的，用户如何知道当前实例中支持的数据源（例如上述的 jsonStr） 有哪些呢？

可以通过如下指令来查看当前实例支持的数据源（内置或者通过插件安装的）：

```sql
!show datasources;
```

2）用户如果想知道某个数据源是否支持该怎么做？

可以通过 **模糊匹配** 来定位某个数据源是否支持。

例如，我们想要知道是否支持读取 `csvStr`：

```sql
!show datasources;
!lastCommand named datasources;
select * from datasources where name like "%csv%" as output;
```

3）当用户想知道数据源对应的一些参数时该如何查看？

可以通过如下命令查看，例如这里我们想要知道 `csv` 支持的相关参数：

```sql
!show datasources/params/csv;
```



### 3. Load 和 Connect 句式的配合使用

`load` 支持 `connect` 语句的引用。

比如：

```sql
select 1 as a as tmp_article_table;

connect jdbc where
url="jdbc:mysql://127.0.0.1:3306/wow?characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&tinyInt1isBit=false"
and driver="com.mysql.jdbc.Driver"
and user="xxxxx"
and password="xxxxx"
as db_1;

load jdbc.`db_1.crawler_table` as output;
```

在这个例子中，我们通过`connect` 语句去连接了一个 jdbc 数据源，再通过 Load 语句读取该数据源中对应的库表。

此处`connect` 语句并不是真的去连接数据库，而仅仅是方便后续记在同一数据源，避免在 `load/save` 句式中反复填写相同的参数。

对于示例中的 `connect` 语句， jdbc + db_1 为唯一标记。 当系统遇到下面 `load` 语句中jdbc.`db_1.crawler_table` 时，他会通过 jdbc 以及 db_1 找到所有的配置参数， 如 driver， user, url, 等等，然后自动附带上到 `load` 语句中。



### 4. 直接查询模式(DirectQuery)

有部分数据源支持直接查询模式，目前官方内置了 JDBC 数据源直接查询模式的支持。

示例：

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

在 JDBC 数据源的 `where/options` 参数里，用户可以配置一个 `directQuery` 参数。
该参数可以写数据源原生支持的语法。比如对于 ClickHouse 可能就是一段合乎 ClickHouse 用法的 SQL, 而对于 MySQL 则可能是合乎 MySQL 语法的 SQL。

Byzer-lang 会将 `directQuery` 的查询下推到底层引擎，并且将执行的结果作为注册成新的表。 
在上面的例子中，新表名称为 `newtable`。 这个表可以被后续的 Byzer-lang 代码引用。

