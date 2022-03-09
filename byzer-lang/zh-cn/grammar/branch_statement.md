# 分支/If|Else

> 类似传统编程语言，Byzer-lang 有变量，宏函数，也有分支语句结构。

## 基本用法

一段最简单的分支语法示例：

```sql
set a = "wow,jack";
!if ''' split(:a,",")[0] == "jack" ''';
   select 1 as a as b;
!else;
   select 2 as a as b;
!fi;

select * from b as output;
```

结果为：a：2。

`!if/!else`  在 Byzer-lang 中并非关键字,都是 [宏函数](/byzer-lang/zh-cn/grammar/macro.md)。

在上面的示例中， 先通过变量申明得到一个变量 `a`。 然后在宏函数 `!if` 只接受一个位置参数，因为是一个宏函数，调用的最后必须加上分号 `;` 。

`!if` 后面接一个文本参数，该文本的内容是一个表达式。在表达式里可以使用 Spark SQL 支持所有函数。比如上面的例子是 `split` 函数。

表达式也支持使用 register 句式注册的函数，本文后面部分会有使用示例。 

在条件表达式中使用 `:` 来标识一个变量。变量来源于 [set 句式](/byzer-lang/zh-cn/grammar/set.md)。比如示例中表达式的 `:a` 变量对应的值为 "wow,jack" 。

如果表达式： 

```sql
split(:a,",")[0] == "jack" 
```

返回 true ， 那么会执行 

```sql
select 1 as a as b;
```

这条 `select` 语句会通过 `as 语法` 生成一个临时表 `b`, 该表只有一个 `a` 字段，并且值为 `1`.

返回 false， 那么会执行

```
select 2 as a as b;
```

这条 `select` 语句会通过 `as 语法` 生成一个临时表 `b`, 该表只有一个 `a` 字段，并且值为 `2`.

示例代码最后通过下列语句对 `b` 表进行输出：

```sql
select * from b as output;
```

从上面的例子可以看到，Byzer-lang 的条件判断语句具有以下特色：

1. 语法设计遵循 SQL 的一些原则。比如采用 `and/or` 替代 `&&/||`。使用 `select` 语句做变量赋值
2. 兼容 Spark SQL 函数
3. 支持用户自定义函数（参看文章后半部分）

## 分支语句嵌套

Byzer-lang 也支持分支语句的嵌套。

示例：

```sql
set a="jack,2";

!if ''' select split(:a,",")[0] as :name, split(:a,",")[1] as :num;
:name == "jack" and :num == 3
''';
    select 0 as a as b;
!elif ''' select split(:a,",")[1] as :num; :num==2 ''';
    !if ''' 2==1 ''';
       select 1.1 as a as b;
    !else;
       select 1.2 as a as b;
    !fi;
!else;
  select 2 as a as b;
!fi;


select * from b as output;
```

在上述代码中，`!if` 表达式里变得复杂了：

```sql
!if ''' select split(:a,",")[0] as :name, split(:a,",")[1] as :num;
:name == "jack" and :num == 3
''';
```

和第一个例子不同之处在于多了一个 `select` 句法结构， 该结构如下：


```sql
select split(:a,",")[0] as :name, split(:a,",")[1] as :num;
```

在上面的示例代码中，通过 `select` 生成了 `:name` 和 `:num` 两个变量。

接着，用户可以使用 `;` 对提交表达式的不同语句进行分割。 第二条语句是对新产生的两个变量进行条件表达式判定：

```sql
:name == "jack" and :num == 3
```

Byzer-lang 会在执行时对变量 `:num` 自动进行类型转换，转换为数字。

## 表达式中变量的作用域

在 `!if/!elif` 里申明的变量有效范围是整个 `!if/!fi` 区间。子 `!if/!else` 语句可以使用上层 `!if/!else` 语句的变量。 


对于以下示例：

```sql
set name = "jack";
!if '''select :name as :newname ;:name == "jack" ''';
    !if ''' :newname == "jack" ''';
       !println '''====1''';
    !else;
       !println '''====2 ''';
    !fi;
!else;
   !println '''=====3''';
!fi;
```

该语句输出为 `====1`，子 `!if` 语句中使用了上层 `!if` 语句中的 `select` 产生的 `:newname` 变量。

同样的，用户也可以在分支语句内部的代码中引用条件表达式里的变量，比如：

```sql
set name = "jack";
!if '''select concat(:name,"dj") as :newname ;:name == "jack" ''';
    !if ''' :newname == "jackdj" ''';
       !println '''====${newname}''';
       select "${newname}" as a as b;
    !else;
       !println '''====2 ''';
    !fi;
!else;
   !println '''=====3''';
!fi;

select * from b as output;
```

在该示例中，用户在 `select`, `!println` 语句里通过 `${}` 引用了 `!if` 或者 `!elif` 里声明的变量。


## 结合 defaultParam 变量

条件分支语句可以与强大的变量声明语法结合。

这里主要介绍和 [defaultParam 变量](/byzer-lang/zh-cn/grammar/set.md) 的结合。

比如：

```sql
set a = "wow,jack" where type="defaultParam";
!if ''' split(:a,",")[0] == "jack" ''';
   select 1 as a as b;
!else;
   select 2 as a as b;
!fi;

select * from b as output;

```

此时代码的输出会是 `2`。 但是如果在前面加一句：

```sql
set a = "jack,";
set a = "wow,jack" where type="defaultParam";
!if ''' split(:a,",")[0] == "jack" ''';
   select 1 as a as b;
!else;
   select 2 as a as b;
!fi;

select * from b as output;
```

这个时候会输出 `1`。 这意味着，用户可以通过执行脚本时，动态在脚本最前面添加一些变量就可以覆盖掉脚本原有的变量，从而实现更加动态的控制脚本的执行流程。


## 在条件表达式中使用自定义函数

前面提到, Byzer-lang 支持使用自定义 UDF 函数，经过注册的 UDF 函数，也可以用在条件分支语句中的条件表达式中。

示例：

```sql
register ScriptUDF.`` as title where 
lang="scala"
and code='''def apply()={
   "jack"
}'''
and udfType="udf";

!if ''' title() == "jack" ''';
   select 1 as a as b;
!else;
   select 2 as a as b;
!fi;

select * from b as output;
```

## !if/!else 子语句中表的生命周期问题以及解决办法

在 Byzer-lang 中，表的生命周期是 session 级别的。这意味着在一个 session 中， 表都是会被自动注册在系统中的，除非被删除或者被重新定义了亦或是 session 失效。
session 级别的生命周期主要配套 notebook 使用，方便用户进行调试。 然而，这在使用 `!if/!else` 的时候则会有困惑发生。

来看下面这个例子：

```sql
!if ''' 2==1 ''';
   select 1 as a as b;
!else;   
!fi;

select * from b as output;
```

当第一次运行的时候，因为 `2==1` 会返回 false， 所以会执行 `!else` 后面的空分支。 接着我们再引用 `b` 进行查询，系统会报错，因为没有表 `b`。 

于是我们修改下条件，将 `2==1` 修改为 `1==1` 时，此时，系统执行了 `select 1 as a as b;`, 产生了 `b` 表， 整个脚本正常运行。 

再次，我们将 `1==1` 再次修改为 `2==1` 此时，系统输出了和条件 `1==1` 时一样的结果。这显然不符合逻辑。

原因在于，系统记住了上次运行的 `b`,所以虽然当前没有执行 `select` 语句，但是依然有输出，从而造成错误。

解决办法有两个：

1. 请求参数设置 `sessionPerRequest`,这样每次请求表的生命周期都是 `request`。
2. 在脚本里备注 `set __table_name_cache__ = "false";` 让系统不要记住表名，逻辑上是每次执行完脚本后，系统自动清理产生运行产生的临时表。

其中第二个办法的使用示例如下：

```sql
set __table_name_cache__ = "false";
!if ''' 2==1 ''';
   select 1 as a as b;
!else;   
!fi;

select * from b as output;
```
