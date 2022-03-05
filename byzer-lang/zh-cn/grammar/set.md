## 变量/Set

Byzer-lang 支持变量。

## 基础应用

```sql
set hello="world";
```

此时用户运行后不会有任何输出结果。

如果希望看到此变量，可以通过 `select` 语句进行查看。

示例：

```sql

set hello="world";

select "hello ${hello}" as title 
as output;
```

得到结果如下：


|title|
|----|
|hello world|

通常， 变量可以用于任何语句的任何部分。甚至可以是结果输出表名，比如下面的例子


```sql

set hello="world";

select "hello William" as title 
as `${hello}`;

select * from world as output;
```

在上面代码中，并没有显式的定义 `world` 表，但用户依然可以在 `select` 语句中使用 `world` 表。

> 表名需要使用反引号将其括起来，避免语法解析错误

### 生命周期

值得一提的是，`set` 语法当前的生命周期是 `request` 级别的，也就是每次请求有效。

通常在 Byzer-lang 中，生命周期分成三个部分：

1. request （当前执行请求有效/ Notebook 中实现为 Cell 等级）
2. session  （当前会话周期有效 /Notebook 的用户等级）
3. application （全局应用有效，暂不支持）


`request` 级别表示什么含义呢？ 如果你先执行

```sql
set hello="world";
```

然后再单独执行

```sql
select "hello William" as title 
as `${hello}`;

select * from world as output;
```

系统会提示报错：

```
Illegal repetition near index 17
((?i)as)[\s|\n]+`${hello}`
                 ^
java.util.regex.PatternSyntaxException: Illegal repetition near index 17
((?i)as)[\s|\n]+`${hello}`
                 ^
java.util.regex.Pattern.error(Pattern.java:1955)
java.util.regex.Pattern.closure(Pattern.java:3157)
java.util.regex.Pattern.sequence(Pattern.java:2134)
java.util.regex.Pattern.expr(Pattern.java:1996)
java.util.regex.Pattern.compile(Pattern.java:1696)
java.util.regex.Pattern.<init>(Pattern.java:1351)
java.util.regex.Pattern.compile(Pattern.java:1028)
java.lang.String.replaceAll(String.java:2223)
tech.mlsql.dsl.adaptor.SelectAdaptor.analyze(SelectAdaptor.scala:49)
```

系统找不到 ${hello} 这个变量,然后原样输出，最后导致语法解析错误。

如果你希望变量可以跨 cell ( Notebook中 )使用，可以通过如下方式来设置。

```sql
set hello="abc" where scope="session";
```

变量默认生命周期是 `request`。 也就是当前脚本或者当前 cell 中有效。 


## 变量类型

Byzer-lang 的变量被分为五种类型：

1. text
2. conf
3. shell
4. sql
5. defaultParam

第一种text， 前面演示的代码大部分都是这种变量类型。

示例：

```sql
set hello="world";
```

第二种conf表示这是一个配置选项，通常用于配置系统的行为，比如 

```sql
set spark.sql.shuffle.partitions=200 where type="conf";
```

该变量表示将底层 Spark 引擎的 shuffle 默认分区数设置为 200。 


第三种是 shell，也就是 `set` 后的 key 最后是由 shell 执行生成的。 

> 不推荐使用该方式， 安全风险较大

典型的例子比如：

```sql
set date=`date` where type="shell";
select "${date}" as dt as output;
```
注意，这里需要使用反引号括住该命令。

输出结果为：

|dt|
|----|
|`Mon Aug 19 10:28:10 CST 2019`|

第四种是 `sql` 类型，这意味着 `set` 后的 key 最后是由 sql 引擎执行生成的。下面的例子可以看出其特点和用法：

```sql
set date=`select date_sub(CAST(current_timestamp() as DATE), 1) as dt` 
where type="sql";

select "${date}" as dt as output;
```

注意这里也需要使用反引号括住命令。 最后结果输出为：

|dt|
|----|
|2019-08-18|

最后一种是defaultParam。

示例：

```sql
set hello="foo";
set hello="bar";

select "${hello}" as name as output;
```

结果输出是

```
name

bar
```

这符合大家直觉，下面的会覆盖上面的。那如果用户想达到这么一种效果，如果变量已经设置了，新变量声明就失效，如果变量没有被设置过，则生效。
为了达到这个效果，Byzer-lang 引入了 `defaultParam` 类型的变量：

```sql
set hello="foo";
set hello="bar" where type="defaultParam";

select "${hello}" as name as output;
```

最后输出结果是：

```
name

foo
```

如果前面没有设置过 `hello="foo"`,


```sql
set hello="bar" where type="defaultParam";

select "${hello}" as name as output;
```

则输出结果为

```
name

bar
```

## 编译时和运行时变量

Byzer-lang 有非常完善的权限体系，可以轻松控制任何数据源到列级别的访问权限，而且创新性的提出了预处理时权限，
也就是通过静态分析 Byzer-lang 脚本从而完成表级别权限的校验（列级别依然需要运行时完成）。

但是预处理期间，权限最大的挑战在于 `set` 变量的解析，比如：

```sql
select "foo" as foo as foo_table;
set hello=`select foo from foo_table` where type="sql";
select "${hello}" as name as output; 
```

在没有执行第一个句子，那么第二条 `set` 语句在预处理期间执行就会报错，因为此时并没有叫 `foo_table` 的表。

为了解决这个问题，Byzer-lang 引入了 `compile/runtime` 两个模式。如果用户希望在 `set` 语句预处理阶段就可以 evaluate 值，那么添加该参数即可。

```sql
set hello=`select 1 as foo ` where type="sql" and mode="compile";
```

如果希望 `set` 变量，只在运行时才需要执行，则设置为 `runtime`:

```sql
set hello=`select 1 as foo ` where type="sql" and mode="runtime";
```

此时，Byzer-lang 在预处理阶段不会进行该变量的创建。


## 内置变量

Byzer-lang 提供了一些内置变量，看下面的代码：

```sql
set jack='''
 hello today is:${date.toString("yyyyMMdd")}
''';
```

`date` 是内置的，你可以用他实现丰富的日期处理。
