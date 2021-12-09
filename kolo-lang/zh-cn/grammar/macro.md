## 宏函数/Macro Function

Kolo-lang 中的宏函数和select句式中函数是不一样的。 宏函数主要是为了复用kolo-lang代码。

比如，我们加载excel的代码如下：

```sql
load excel.`./example-data/excel/hello_world.xlsx` 
where header="true" 
as hello_world;

select hello from hello_world as output;
```

如果每次都写完整的load语句，可能会比较繁琐。此时用户可以将其封装成一个宏函数：

```sql
set loadExcel = '''
load excel.`{0}` 
where header="true" 
as {1}
''';

!loadExcel ./example-data/excel/hello_world.xlsx helloTable;

```

分成两步，第一步是定义一个变量，该变量的值为一段Kolo-lang代码。代码中的`{0}`,`{1}` 等为位置参数，会在调用的时候被替换。
第二步，我们使用`!` 来将变量转化为宏函数，参数传递则使用类似命令行的方式。如果参数中包含空格等特殊字符，可以将参数括起来：

```sql
set loadExcel = '''
load excel.`{0}` 
where header="true" 
as {1}
''';

!loadExcel "./example-data/excel/hello_world.xlsx" "helloTable";
```

我们也支持命名参数：

```sql
set loadExcel = '''
load excel.`${path}` 
where header="true" 
as ${tableName}
''';

!loadExcel _ -path ./example-data/excel/hello_world.xlsx -tableName helloTable;
```

注意，为了识别命名参数，我们要求第一个参数是`_` 。

### 宏函数的限制

对于变量中的kolo-lang代码要作为宏函数使用，目前也有几个限制：

1. 最后一条语句不需要分号。
2. 宏函数里不能嵌套宏函数。

第二个，比如下面代码是非法的：

```sql
set hello = '''
!hdfs -ls /;
select 1 as a as output
''';

!hello;
```

该语句包含了一个内置的宏函数 !hdfs, 所以是非法的。
