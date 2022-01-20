# Data Transform/Select

The `select` syntax is one of the most important ways of processing data in Byzer-lang. `ET` syntax (applied to run/train/predict ) is also important.

> The `select` syntax in Byzer-lang is fully compatible with Spark SQL except for the last `as tablename`.

## Basic grammar

The simplest `select` statement is as follows:

```sql
select 1 as col1
as table1;
```

From the above code, you can see the only difference between the `select` syntax in Byzer-lang and the traditional SQL `select` syntax is that there is an additional `as tableName</g3 >.
This minor improvement helps reference the results of this SQL processing later.

For example, for `table1`, users can refer to it in the new `select` statement:

```sql
select 1 as col1
as table1;

select * from table1 as output;
```


## Template functions in select syntax

Actually a `select` statement can be quite verbose. Byzer-lang provides some methods to help you simplify your codes.

For the following codes example:

```sql
select "" as features, 1 as label as mockData;

select
SUM( case when features is null or features='' then 1 else 0 end ) as features,
SUM( case when label is null or label='' then 1 else 0 end ) as label,
1 as a from mockData as output;
```

If there are too many fields and users use these codes to do similar things, users need to write a lot of SUM statements.

Users can make improvements with the following syntax:

```sql
select "" as features, 1 as label as mockData;

select
#set($colums=["features","label"])
#foreach( $column in $colums )
    SUM( case when `$column` is null or `$column`='' then 1 else 0 end ) as $column,
#end
 1 as a from mockData as output;
```

Among them, `#set` sets a template variable `$columns`, and then `#foreach` is used to loop over the variable, and the SUM inside the codes becomes a template in essential.
When the system executes the `select` statements, it will automatically expand into code similar to the previous handwritten code according to these instructions.

Byzer-lang also provides an easier-to-use template:

```sql
 set sum_tpl = '''
SUM( case when `{0}` is null or `{0}`='' then 1 else 0 end ) as {0}
''';

select ${template.get("sum_tpl","label")},
${template.get("sum_tpl","label")}
from mockData as output;
```

Set up a template via variable declaration, which is held by a variable named `sum_tpl` and supports positional parameters. Next, the template is rendered by using `${template.get}` in the `select` syntax.
The first parameter is the template name and the following parameters are the parameters of the template.

