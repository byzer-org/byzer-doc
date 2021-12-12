## 分支/If|Else

> 类似传统编程语言，Kolo-lang 有变量，宏函数，也有分支语句结构。

### 基本用法

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

if/else 在Kolo-lang 中，其实并非关键字，他们其实都是一个宏函数。因为宏函数的调用非常像命令行，所以其实学习门槛
也会更低。

在上面的示例中， 先通过变量申明得到一个变量 `a`。 然后在 宏函数 `!if` 只接受一个位置参数，因为是一个宏函数，调用的最后极为必须加上分号 `;` 。

`!if` 后面接一个文本参数，该文本的内容是一个表达式。在表达式里可以使用大部分SQL支持的函数。比如上面的例子是 split 函数。

表达式也也支持使用 register 句式注册的函数，本文后面部分会有使用示例。 

在条件表达式中使用 `:` 来标识一个变量。变量来源于 set 句式。比如示例中表达式的 :a 变量对应的值为 "wow,jack" 。

如果表达式： 

```sql
split(:a,",")[0] == "jack" 
```

返回 true ， 那么会执行 

```sql
select 1 as a as b;
```

这条语句会产生一个表 b, 该表仅有一个字段 a，并且值为 1。反之，则产生表 b，该表也是有一个字段为 a，但值为2。 

示例代码最后通过下列语句对 b 表进行输出：

```sql
select * from b as output;
```

从上面的例子可以看到，Kolo-lang 的条件判断语句具有以下特色：

1. 语法设计遵循 SQL 的一些原则。比如采用 and/or 替代 &&,||。使用 select 语句做变量赋值
2. 兼容大部分 SQL 函数
3. 支持多个语句，最后一条语句作为最后的条件
4. 支持用户自定义函数（参看文章后半部分）

### 分支语句嵌套


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

再来看 !if 语句：

```sql
!if ''' select split(:a,",")[0] as :name, split(:a,",")[1] as :num;
:name == "jack" and :num == 3
''';
```

和第一个例子有些不同，因为要对 :a 变量进行多次处理，为了使得最后的表达式更加简单，Kolo-lang 支持通过 select 语法来做变量赋值。


```sql
select split(:a,",")[0] as :name, split(:a,",")[1] as :num;
```

在上面的示例代码中，通过select 生成了 :name 和 :num 两个变量。

接着，可以使用者两个变量进行条件表达式判定：

```sql
:name == "jack" and :num == 3
```

Kolo-lang 会对变量 `:num` 自动进行类型转换。

### 表达式中变量的作用域

在 !if/!elif 里申明的变量有效范围是整个 !if/!fi 区间。子 !if/!else 语句可以看到上层 !if/!else 语句的变量。 

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

该语句输出为 `====1`，子 !if 语句中使用了上层 !if 语句中的 select 产生的 :newname 变量。

同样的，用户也可以在在分支语句内部中引用 条件表达式里的变量，比如：

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

在该示例中，用户在 select, !println 语句里通过 `${}` 引用了 !if 或者 !elif 里声明的变量。


### 结合 defaultParam 变量

条件分支语句结合强大的变量声明语法，其实可以做很多有意思的事情，比如：

```sql
set a = "wow,jack" where type="defaultParam";
!if ''' split(:a,",")[0] == "jack" ''';
   select 1 as a as b;
!else;
   select 2 as a as b;
!fi;

select * from b as output;

```

此时代码的输出会是 2。 但是如果在前面加一句：

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

这个时候会输出 1。 也就是用户可以通过添加 set 变量覆盖已经存在的变量从而控制脚本的执行。


### 在条件表达式中使用自定义函数

前面提到, Kolo-lang 支持使用自定义 UDF 函数，并且在 !if 的条件表达式中使用。

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

### !if/!else 子语句中表的生命周期问题以及解决办法

在 Kolo-lang 中，表的生命周期是session级别的。这意味着当一个表被使用过后，系统会自动记住。这样可以很方便的用户进行调试。 但是当使用 !if/!else 的时候则会有困惑发生。

来看下面这个例子：

```sql
!if ''' 2==1 ''';
   select 1 as a as b;
!else;   
!fi;

select * from b as output;
```

当一次运行的时候，系统会报错，因为没有表 b。 如果我们将 2==1 修改为 1==1 时，则系统正常运行。 如果将 1==1 再次修改为 2==1 此时系统依然正常运行。 
因为系统记住了上次运行的 b,所以虽然当前没有执行 select 语句，但是依然有输出，从而造成错误。

解决办法有两个：

1. 请求参数设置 sessionPerRequest,这样每次请求都会保证隔离。
2. 在脚本里备注 set __table_name_cache__ = "false"; 让系统不要记住表名。

其中第二个办法的使用示例如下：

```sql
set __table_name_cache__ = "false";
!if ''' 2==1 ''';
   select 1 as a as b;
!else;   
!fi;

select * from b as output;
```