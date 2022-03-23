# 计算表父子关系插件/TreeBuildExt

在 SQL 中计算父子关系无疑是复杂的，需要复杂的 join 关联，通常而言，用户计算父子关系，一般需要：

1. 任意一个指定节点的所有子子孙孙节点。
2. 任意一个指定节点树状层级
3. 返回一个一个或者多个树状结构

假设我们要处理的数据格式如下：

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

可以看出上表存在父子关系。

在许多运营或市场推广裂变计算的场景中，常常需要统计用户的邀请人数和相应邀请链的深度，则可以使用这个插件快速统计完成。

**假设现想计算指定节点 7 有多少子节点以及其所属的层级，则相应的操作方式如下：**

首先，我们把这个数据映射成表，使用 load 语法加载我们的 json 数据。

```sql
load jsonStr.`jsonStr` as data;
```

如果您当前使用的是 spark3 版本（Byzer 中默认为 spark3 ），则需要设置以下参数：

```shell
set spark.sql.legacy.allowUntypedScalaUDF=true where type="conf";
```

然后便可以用 run 指令使用该模块了：

```sql
run data as TreeBuildExt.`` 
where idCol="id" 
and parentIdCol="parentId" 
and treeType="nodeTreePerRow" 
as result;
```

结果如下：

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
level 是层级，children 则是所有子元素（包括子元素的字元素）。

您还可以直接生成 N 棵树，然后您可以使用自定义 udf 函数继续处理这棵树：

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

children 是一个嵌套 row 结构，可以在 udf 里很好地被处理。

### CacheExt 的配置参数

| 参数名  |  参数含义 |
|---|---|
| idCol | 必填项，节点 id 使用的字段 |
| parentIdCol | 必填项，parent 节点 id 使用的字段 |
| recurringDependencyBreakTimes | 最高级别应低于此值； 当遍历一棵树时，一旦发现一个节点两次，则该子树将被忽略 |
| topLevelMark | 指定首层 id |
| treeType | 如果设置为 true，会立即进行缓存；cache ET 默认懒执行，该参数设置为 true 会立即执行，默认为 false |

