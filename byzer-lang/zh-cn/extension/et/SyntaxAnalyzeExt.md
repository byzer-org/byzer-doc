# 语法解析插件 SyntaxAnalyzeExt
我们知道 Byzer 支持语法解析接口，我们可以通过设置参数 `executeMode` 为 analyze，实现 Byzer 语法的解析。语法解析接口对 set/load 语法解析比较充分，但是 select 语句解析的比较粗糙，只有 raw，sql，tableName 三个部分。在很多场景里面，我们其实需要解析出 SQL 中所有的表，而不仅仅是这条 SQL 中生成的表，我们可以通过 `SyntaxAnalyzeExt` 来完成表的抽取。

使用场景示例：
- 我们需要知道一个 select 语句的所有输入源表

语法解析使用 run 语法，其中 where 子句中，`action`为解析的类型，目前仅支持抽取表功能`extractTables`，也是该 ET 中`action`的缺省值，`sql`为待解析的
 SQL 语句，格式为标准的 Spark SQL，使用方式如下：
```sql
run command as SyntaxAnalyzeExt.`` where 
action="extractTables" and sql='''
select a from table1 as output;
''';
```

下面给一个完整的例子：
首先生成两个表，table1 和 table2。然后执行`SyntaxAnalyzeExt`抽取一个嵌套的 SQL 的所有的表。 如下：

```sql
 select "stub" as table1;
 
 select "stub" as table2;

 run command as SyntaxAnalyzeExt.`` where
 action = "extractTables" and sql='''
 select * from (select * from table1 as c) as d left join table2 as e on d.id=e.id
 ''' as extractedTables;

 select * from extractedTables as output;
```

结果如下：
```
 +----------+
 |tableName |
 +----------+
 |table1    |
 |table2    |
 +----------+
```

另外，我们也支持把 SQL 通过变量方式传入，方式如下：
```
select "test" as col1 as table1;

set test_sql = '''select * from table1 as output''';
 
run command as SyntaxAnalyzeExt.`` where
action = "extractTables" and sql="${test_sql}" as extractedTables;
 
select * from extractedTables as output1;
```
接着就可以使用`!`执行这个变量。
```
!test_sql;
```