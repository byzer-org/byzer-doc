## 数据转换/Select

select句式是Kolo-lang中处理数据最重要的方式之一。之所以说之一，是因为我们还有ET(应用于run/train/predict)。

> Kolo-lang中的select句式兼容Spark SQL. 但是我们对标准的Spark SQL做了一丢丢改进

### 基本语法

最简单的一个select语句：

```sql
select 1 as col1 
as table1;
```

从上面可以看到，Kolo-lang中的select语法和传统SQL中的select语法唯一的差别就是后面多了一个 as tableName。这也是为了方便后续继续对该SQL处理的结果进行处理而引入的微小改良。
有了这个改良，我们可以很方便基于table1继续进行处理，比如：

```sql
select 1 as col1 
as table1;

select * from table1 as output;
```

这样，我们就可以将SQL语句进行串联使用。

### select句式中的模板功能

实际在书写select语句可能会非常冗长。Kolo-lang提供了一些手段帮助大家简化代码。

对于如下代码示例：

```sql
select "" as features, 1 as label as mockData;

select 
SUM( case when features is null or features='' then 1 else 0 end ) as features,
SUM( case when label is null or label='' then 1 else 0 end ) as label,
1 as a from mockData as output;
```

如果字段特别多，而且都要做类似的事情，那么我们可能要写非常多的SUM语句。我们可以通过如下语法进行改进：

```sql
select "" as features, 1 as label as mockData;

select 
#set($colums=["features","label"])
#foreach( $column in $colums )
    SUM( case when `$column` is null or `$column`='' then 1 else 0 end ) as $column,
#end
 1 as a from mockData as output;
```

#set设置了一个模板变量$columns, 然后使用功能 #foreach对该变量进行循环。里面的SUM本质上成了一个模板。但系统在执行该select语句的时候，
会自动展开成我们前面手写的代码。

Kolo-lang还提供了一个更加易用的模板方案：

```sql
 set sum_tpl = '''
SUM( case when `{0}` is null or `{0}`='' then 1 else 0 end ) as {0}
''';

select ${template.get("sum_tpl","label")},
${template.get("sum_tpl","label")}
from mockData as output;
```

我们设置一个模板，该模板通过变量`sum_tpl`持有，并且支持位置参数。接着，我们就可以使用 ${template.get} 对模板进行渲染了。
第一个参数是模板名，后面的参数则是模板的参数。

