# 计算复杂的父子关系

在SQL中计算父子关系无疑是复杂的，需要复杂的join关联，我看到分析师做了一个是个层级的关联，就已经是非常复杂的脚本了，但是
用户依然不买账。通常而言，用户计算父子关系，一般需要：

1. 任意一个指定节点的所有子子孙孙节点。
2. 任意一个指定节点树状层级
3. 返回一个一个或者多个树状结构

假设我们要处理的数据样子是这样的：

```sql
set jsonStr = '''
{"id":0,"parentId":null}
{"id":1,"parentId":null}
{"id":2,"parentId":1}
{"id":3,"parentId":3}
{"id":7,"parentId":0}
{"id":199,"parentId":1}
{"id":200,"parentId":199}
{"id":201,"parentId":199}
''';
```

存在父子关系。

现在我想知道，给定节点7,那么7所有子子孙孙节点有多少，然后层级多深？ 具体的某个场景比如我们在做用户推广时，用户可以邀请，我想知道因为某个用户而邀请到了多少人，
邀请链有多深。

接着我们把这个数据映射成标，大家还记得load script指令吧，使用load语法加载我们的json数据。

```sql
load jsonStr.`jsonStr` as data;
```

如果您当前使用的是spark3版本（byzer中默认为spark3），则需要设置以下参数：

```
set spark.sql.legacy.allowUntypedScalaUDF=true where type="conf";
```

现在可以使用该模块了，我们用run指令：

```sql
run data as TreeBuildExt.`` 
where idCol="id" 
and parentIdCol="parentId" 
and treeType="nodeTreePerRow" 
as result;
```

大概结果是这个样子的：

```
+---+-----+------------------+
|id |level|children          |
+---+-----+------------------+
|200|0    |[]                |
|0  |1    |[7]               |
|1  |2    |[200, 2, 201, 199]|
|7  |0    |[]                |
|201|0    |[]                |
|199|1    |[200, 201]        |
|2  |0    |[]                |
+---+-----+------------------+
```
level是层级，children则是所有子元素（包括子元素的字元素）。

我们还可以直接生成N课书，然后你可以使用自定义udf函数继续处理这棵树：

```sql
run data as TreeBuildExt.`` 
where idCol="id" 
and parentIdCol="parentId" 
and treeType="treePerRow" 
as result;
```

结果如下：

```
+----------------------------------------+---+--------+-----+
|children                                |id |parentID|level|
+----------------------------------------+---+--------+-----+
|[[[], 7, 0]]                            |0  |null    |1    |
|[[[[[], 200, 199]], 199, 1], [[], 2, 1]]|1  |null    |2    |
+----------------------------------------+---+--------+-----+
```

children是一个嵌套row结构，可以在udf里很好的处理。

## CacheExt 的配置参数

| 参数名  |  参数含义 |
|---|---|
| idCol | 必填项，节点id使用的字段 |
| parentIdCol | 必填项，parent节点id使用的字段 |
| recurringDependencyBreakTimes | 最高级别应低于此值； 当遍历一棵树时，一旦发现一个节点两次，则该子树将被忽略 |
| topLevelMark | 指定首层id |
| treeType | 如果设置为true，会立即进行缓存。cache ET默认懒执行，该参数设置为true会立即执行，默认为false |

