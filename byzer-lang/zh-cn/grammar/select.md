# 数据转换/Select

`select` 句式是 Byzer-lang 中处理数据最重要的方式之一。之所以说之一，是因为还有 `ET` (应用于 run/train/predict )。

> Byzer-lang 中的 `select` 句式除了最后 `as 表名` 以外，完全兼容 Spark SQL。

## 基本语法

最简单的一个 `select` 语句：

```sql
select 1 as col1 
as table1;
```

从上面代码可以看到，Byzer-lang 中的 `select` 语法和传统 SQL `select` select 语法唯一的差别就是后面多了一个 `as tableName`。
这也是为了方便后续对该 SQL 处理的结果进行引用引入的微小改良。

比如，对于 `table1`, 用户可以在新的 `select` 语句中进行引用：

```sql
select 1 as col1 
as table1;

select * from table1 as output;
```


## Select 句式中的模板功能

实际在书写 `select` 语句可能会非常冗长。Byzer-lang 提供了一些手段帮助大家简化代码。

对于如下代码示例：

```sql
select "" as features, 1 as label as mockData;

select 
SUM( case when features is null or features='' then 1 else 0 end ) as features,
SUM( case when label is null or label='' then 1 else 0 end ) as label,
1 as a from mockData as output;
```

如果字段特别多，而且都要做类似的事情，可能要写非常多的 SUM 语句。

用户可以通过如下语法进行改进：

```sql
select "" as features, 1 as label as mockData;

select 
#set($colums=["features","label"])
#foreach( $column in $colums )
    SUM( case when `$column` is null or `$column`='' then 1 else 0 end ) as $column,
#end
 1 as a from mockData as output;
```

`#set` 设置了一个模板变量 `$columns`, 然后使用 `#foreach` 对该变量进行循环，里面的 SUM 本质上成了一个模板。
系统在执行该 `select` 语句的时候，会自动根据这些指令展开成类似前面手写的代码。

Byzer-lang 还提供了一个更加易用的模板方案：

```sql
 set sum_tpl = '''
SUM( case when `{0}` is null or `{0}`='' then 1 else 0 end ) as {0}
''';

select ${template.get("sum_tpl","label")},
${template.get("sum_tpl","label")}
from mockData as output;
```

通过变量声明设置一个模板，该模板通过名为 `sum_tpl` 变量持有，并且支持位置参数。接着，在 `select` 句式中使用 `${template.get}` 对模板进行渲染了。
第一个参数是模板名，后面的参数则是模板的参数。

