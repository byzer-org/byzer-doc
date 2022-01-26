# Data transform/Select

`ET` syntax (applied to run/train/predict ) and  `select` syntax are the most important ways for processing data in Byzer-Lang.

> The `select` syntax in Byzer-Lang is fully compatible with Spark SQL except for the last `as tablename`.

## Basic syntax

The simplest  `select` statement is as follows:

```sql
select 1 as col1
as table1;
```

From the above code, we can see the only difference between the `select` syntax in Byzer-Lang and the traditional SQL  is that there is an extra  `as tableName`.
This change is to facilitate the SQL processing.

For example, for `table1`, users can cite it in the new `select` statement:

```sql
select 1 as col1
as table1;

select * from table1 as output;
```


## Templates in `select` syntax

The  `select` statement can be quite long. Byzer-Lang provides some templates to simplify your coding experience.

For the following example codes:

```sql
select "" as features, 1 as label as mockData;

select
SUM( case when features is null or features='' then 1 else 0 end ) as features,
SUM( case when label is null or label='' then 1 else 0 end ) as label,
1 as a from mockData as output;
```

If there are many fields with similar functions, users may need to write a lot of `SUM` statements.

The following syntax can help to simplify this process:

```sql
select "" as features, 1 as label as mockData;

select
#set($colums=["features","label"])
#foreach( $column in $colums )
    SUM( case when `$column` is null or `$column`='' then 1 else 0 end ) as $column,
#end
 1 as a from mockData as output;
```

Among them, `#set` sets a template variable `$columns`, and then use `#foreach` to loop the variable. By doing this, the `SUM` of the codes actually servers as a template. When the system executes the `select` statement, it will automatically write the syntax following the instructions, the same as the syntax written in the above manual coding.

Byzer-Lang also provides a more easier-to-use template:

```sql
 set sum_tpl = '''
SUM( case when `{0}` is null or `{0}`='' then 1 else 0 end ) as {0}
''';

select ${template.get("sum_tpl","label")},
${template.get("sum_tpl","label")}
from mockData as output;
```

Set up a template via variable declaration, and the template will be managed by  `sum_tpl`, which also supports positional parameters. Next, render the template by `${template.get}` in the `select` statement. The first parameter is the template name and the following parameters are the parameters of the template.

