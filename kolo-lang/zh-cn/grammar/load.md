## 数据加载/Load

Kolo-lang 认为一切都可以加载为表，可能是某个文件，也可能是一个Rest 接口，也可能是某数据库，
或者是数仓或者数据湖。 


### 基本使用

我们先来看一个最简单的load语句：

```sql
set abc='''
{ "x": 100, "y": 200, "z": 200 ,"dataType":"A group"}
{ "x": 120, "y": 100, "z": 260 ,"dataType":"B group"}
''';
load jsonStr.`abc` as table1;
```

在这个示例中，我们设置了一个变量，变量名称是abc, 通过jsonStr数据源，使用load语句将这段文本注册成一张视图（表）。运行
结果如下：

```
dataType  x         y   z

A         group	100	200	200
B         group	120	100	260

```

仔细看该语句，第一个关键词是load,紧接着接一个数据源或者格式名称，比如上面的例子是`jsonStr`。这表示我们要加载一个json的字符串，
在后面，我们会接.`abc`.通常 `` 内是个路径。比如 csv.`/tmp/csvfile`，到这一步，Kolo-lang已经知道如何加载数据了，我们最后使用 `as table1`,表示将数据
注册成视图（表），注册的东西后面可以引用。 比如在后续的select语句我们可以直接使用table1：

```sql
set abc='''
{ "x": 100, "y": 200, "z": 200 ,"dataType":"A group"}
{ "x": 120, "y": 100, "z": 260 ,"dataType":"B group"}
''';
load jsonStr.`abc` as table1;
select * from table1 as output;
```

### 获取可用数据源

我们可以通过如下指令来查看当前支持的数据源：

```
!show datasources;
```

用户可以通过模糊匹配来定位某个数据源是否存在：

```
!show datasources;
!lastCommand named datasources;
select * from datasources where name like "%csv%" as output;
```

当用户想知道数据源(如csv)的一些参数时，可以通过如下命令查看：

```
!show datasources/params/csv;
```

### 直接查询模式(DirectQuery)

有部分数据源支持直接查询模式。这里我们以JDBC数据源为例。

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

我们看到，在jdbc数据源的where/options参数里，用户可以配置一个directQuery参数。该参数可以写数据源原生支持的语法。比如对于MogoDB可能就是一段json,而对于
MySQL则可能是合乎MySQL语法的SQL。

通过该功能，我们可以将directQuery执行的结果作为新的表，在上面的例子中为 newtable. 之后我们就可以在后续的select语句中进行引用。