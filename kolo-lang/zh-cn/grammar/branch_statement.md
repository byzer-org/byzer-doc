## 分支/If|Else

> 类似传统编程语言，Kolo-lang有变量，宏函数，也有分支语句结构。

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

if/else 在Kolo-lang中，其实并非关键字，他们其实都是一个宏函数。因为宏函数的调用非常像命令行，所以其实学习门槛
也会更低。

在上面的示例中， 先通过变量申明得到一个变量`a`。 然后在 宏函数`!if` 只接受一个位置参数，因为是一个宏函数，调用的最后极为必须加上分号`;` 。

`!if` 后面接一个文本参数，该文本的内容是一个表达式。在表达式里，我们可以使用大部分SQL支持的函数。比如上面的例子是split函数,也开始使用register 句式注册的函数，我们会在本文后面部分有使用示例。 

在条件表达式中，我们使用":"来标识一个变量。变量来源于set句式。比如示例中表达式的:a变量对应的值为"wow,jack",他是通过set句式来设置的。

如果表达式 

```sql
split(:a,",")[0] == "jack" 
```

返回true, 那么会执行 

```sql
select 1 as a as b;
```

这条语句会产生一个表b, 该表仅有一个字段a,并且值为1。反之，则产生表b, 该表也是有一个字段为a,但值为2。 
最后我们通过下列语句对b表进行输出：

```sql
select * from b as output;
```

从上面的例子可以看到，Kolo-lang的条件判断语句具有以下特色：

1. 语法设计遵循SQL的一些原则。比如采用 and/or 替代 &&,||.使用select语句做变量赋值
2. 兼容大部分SQL函数
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

我们再来看 !if 语句：

```sql
!if ''' select split(:a,",")[0] as :name, split(:a,",")[1] as :num;
:name == "jack" and :num == 3
''';
```

和第一个例子有些不同，因为我们要对:a变量进行多次处理，为了使得最后的表达式更加简单，Kolo-lang支持通过select语法来做变量赋值。对于语句

```sql
select split(:a,",")[0] as :name, split(:a,",")[1] as :num;
```

我们得到了:name 和:num两个变量。之后通过";"表示该语句的结束。在后续的语句中我们就可以引用对应的变量了：

```sql
:name == "jack" and :num == 3
```

Kolo-lang会对变量`:num`自动进行类型转换。

### 表达式中变量的作用域

在!if/!elif里申明的变量有效范围是整个!if/!fi区间。子if/else语句可以看到上层if/else语句的变量。 对于以下示例：

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

该语句输出为====1，我们在子if语句中使用了上面的 select产生的:newname变量。

同样的，我们也可以在子语句里方便的使用条件表达式里的变量：

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

我们可以在!if/!else的子语句里，使用select,!println等语句里通过原先的'${}'符号引用!if或者!elif里申明的变量。


### 结合defaultParam 变量

条件分支语句结合强大的set语法，其实可以做很多有意思的事情，比如：

```sql
set a = "wow,jack" where type="defaultParam";
!if ''' split(:a,",")[0] == "jack" ''';
   select 1 as a as b;
!else;
   select 2 as a as b;
!fi;

select * from b as output;

```

此时他的输出会是2。 但是如果你在前面加一句：

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

这个时候会输出1. 也就是用户可以通过添加set变量覆盖已经存在的变量从而控制脚本的执行。


### 在条件表达式中使用自定义函数

前面我们提到,Kolo-lang支持使用自定义UDF函数，并且在!if语句中也是可以使用的。比如：

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

因为在Kolo-lang中表的生命周期是session级别的。这意味着当一个表被使用过后，系统会自动记住。这样可以很方便的用户进行调试。 但是当使用if/else的时候则会有困惑发生。

我们来看下面这个例子：

```sql
!if ''' 2==1 ''';
   select 1 as a as b;
!else;   
!fi;

select * from b as output;
```

当一次运行的时候，系统会报错，因为没有表b. 如果我们将2==1 修改为 1==1 时，则系统正常运行。 然后我们将1==1 再次修改为2==1 此时系统依然正常运行。 因为系统记住了上次运行的b,所以虽然当前没有执行select语句，但是依然有输出，从而造成错误。

解决办法有两个：

1. 请求参数设置sessionPerRequest,这样每次请求都会保证隔离。
2. 在脚本里备注set __table_name_cache__ = "false"; 让系统不要记住表名。

其中第二个办法的使用示例如下：

```sql
set __table_name_cache__ = "false";
!if ''' 2==1 ''';
   select 1 as a as b;
!else;   
!fi;

select * from b as output;
```