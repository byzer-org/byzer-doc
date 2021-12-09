## 数据转换/Select

Kolo-lang的select 语句，兼容Spark SQL。 我们唯一做的改动是最后必须加上 `as 表名`。

### 基本语法

最简单的一个select语句：

```sql
select 1 as col1 
as table1;
```

语句之间可以衔接，比如：

```sql
select 1 as col1 
as table1;

select * from table1 as output;
```

这里，output 没有特殊含义，只是约定的作为输出展示用的表名，该表名一般不会再被引用。

### 