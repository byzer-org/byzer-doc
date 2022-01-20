# Macro Function

The macro function in Byzer-lang is different from the function in the `select` statement. Macro functions are mainly used to reuse Byzer-lang code.

## Basic usage

Take the code to load the `excel` file as an example:

```sql
load excel.`./example-data/excel/hello_world.xlsx`
where header="true"
as hello_world;

select hello from hello_world as output;
```

If you write the complete `load` statement every time, it may be cumbersome. At this point users can encapsulate it into a macro function:

```sql
set loadExcel = '''
load excel.`{0}`
where header="true"
as {1}
''';

!loadExcel ./example-data/excel/hello_world.xlsx helloTable;

```

In the sample code above, it is divided into two steps. The first step is to define a variable whose value is a Byzer-lang code. `{0}` , `{1}`in the code are positional parameters and will be replaced when called.
The second step is to use `!` to implement macro function calls, and use a command-line-like way to pass parameters.

If the parameter contains special characters such as spaces, you can enclose the parameter:

```sql
set loadExcel = '''
load excel.`{0}`
where header="true"
as {1}
''';

!loadExcel "./example-data/excel/hello_world.xlsx" "helloTable";
```

Macro functions also support named parameters:

```sql
set loadExcel = '''
load excel.`${path}`
where header="true"
as ${tableName}
''';

!loadExcel _ -path ./example-data/excel/hello_world.xlsx -tableName helloTable;
```

The parameters after `-path` correspond to `${path}` in the `loadExcel` function body. The same is true for `tableName` .

Note: in order to recognize named arguments, the macro function requires that the first argument be `_` .

## Scope

After the macro function is declared, the scope can be used. The declaration can be repeated and the later declaration will override the previous declaration.

## Limitations of macro functions

The use of macro functions currently has several limitations:

1. In the macro function body, the last statement does not need a semicolon
2. Macro functions cannot be nested within macro functions

The first limitation is easier to understand.

The second limitation can be demonstrated by the following code:

```sql
set hello = '''
!hdfs -ls /;
select 1 as a as output
''';

!hello;
```

The statement contains a built-in macro function `!hdfs`, so it is illegal.
