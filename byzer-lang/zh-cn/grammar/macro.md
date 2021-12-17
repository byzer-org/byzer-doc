# 宏函数/Macro Function

Byzer-lang 中的宏函数和 `select` 句式中函数是不一样的。 宏函数主要是为了复用 Byzer-lang 代码。

## 基础用法

以加载 `excel` 文件的代码为例:

```sql
load excel.`./example-data/excel/hello_world.xlsx` 
where header="true" 
as hello_world;

select hello from hello_world as output;
```

如果每次都写完整的 `load` 语句，可能会比较繁琐。此时用户可以将其封装成一个宏函数：

```sql
set loadExcel = '''
load excel.`{0}` 
where header="true" 
as {1}
''';

!loadExcel ./example-data/excel/hello_world.xlsx helloTable;

```

在上面示例代码中，分成两步，第一步是定义一个变量，该变量的值为一段 Byzer-lang 代码。代码中的 `{0}` , `{1}` 等为位置参数，会在调用的时候被替换。
第二步，使用 `!` 实现宏函数的调用，参数传递则使用类似命令行的方式。

如果参数中包含空格等特殊字符，可以将参数括起来：

```sql
set loadExcel = '''
load excel.`{0}` 
where header="true" 
as {1}
''';

!loadExcel "./example-data/excel/hello_world.xlsx" "helloTable";
```

宏函数也支持命名参数：

```sql
set loadExcel = '''
load excel.`${path}` 
where header="true" 
as ${tableName}
''';

!loadExcel _ -path ./example-data/excel/hello_world.xlsx -tableName helloTable;
```

`-path` 后面的参数对应  `loadExcel` 函数体里的 `${path}`, 同理 `tableName`。

注意，为了识别命名参数，宏函数要求第一个参数是 `_` 。

## 作用域

宏函数声明后即可使用。 可以重复声明，后声明的会覆盖前面声明的。

## 宏函数的限制

宏函数的使用，目前也有几个限制：

1. 宏函数体里，最后一条语句不需要分号
2. 宏函数里不能嵌套宏函数

第一条限制比较容易理解。

第二条限制可以通过下面的代码来展示：

```sql
set hello = '''
!hdfs -ls /;
select 1 as a as output
''';

!hello;
```

该语句包含了一个内置的宏函数 `!hdfs`, 所以是非法的。
