### Byzer 支持 JDBC 聚合下推

> 聚合下推PR链接 [聚合下推](https://github.com/byzer-org/byzer-lang/pull/1414)

我们知道 Byzer 支持多数据源和联邦查询，可以方便分析师在一个平台上快速的分析来自多种数据源的数据，从而进行灵活的探索式分析。

#### 使用场景和优势

当前 Byzer 中加载数据的方式会拉取明细数据到 spark 中进行聚合计算，对于小数据量或者在分布式文件系统上的数据源来说是常规操作。但是对于 JDBC 数据源或者有分析能力的 OLAP 系统来说拉取明细数据可能就不是最优选择了，对于这类数据源如果能够把聚合查询下压到数据源中去处理，则既可以利用数据源的聚合查询能力又可以减少  JDBC 拉取数据量，从而进一步提高分析效率。Byzer 在拥有聚合下推能力之后，可以给分析师带来更高效的分析体验。

我们以 Byzer 举例子，假设有两张表 kylin_sales_my1 和 kylin_sales_my2，做 join 和聚合查询：

```sql
connect jdbc where 
url="jdbc:mysql://localhost:3306/learn_kylin?characterEncoding=utf8"
and driver="com.mysql.jdbc.Driver"
and user="root"
and password="yourpassword"
as db_1;

load jdbc.`db_1.kylin_sales_my1` as kylin_sales_my1;
load jdbc.`db_1.kylin_sales_my2` as kylin_sales_my2;

select t1.BUYER_ID, t1.ss, t2.ss as s2 from 
(select BUYER_ID,sum(price) as ss from kylin_sales_my1 where OPS_REGION="Shanghai" group by BUYER_ID) t1 
join 
(select BUYER_ID,sum(price) as ss from kylin_sales_my2 group by BUYER_ID) t2 
on t1.BUYER_ID=t2.BUYER_ID 
as output;
```

生成的查询计划如下，会直接从 Byzer 数据源中拉取明细数据：

```
SubqueryAlias `output`
+- Project [BUYER_ID#32L, ss#61, ss#62 AS s2#63]
   +- Join Inner, (BUYER_ID#32L = BUYER_ID#52L)
      :- SubqueryAlias `t1`
      :  +- Aggregate [BUYER_ID#32L], [BUYER_ID#32L, sum(price#34) AS ss#61]
      :     +- Filter (OPS_REGION#33 = Shanghai)
      :        +- SubqueryAlias `kylin_sales_my1`
      :           +- Project [BUYER_ID#26L AS BUYER_ID#32L, OPS_REGION#27 AS OPS_REGION#33, price#28 AS price#34]
      :              +- Relation[BUYER_ID#26L,OPS_REGION#27,price#28] JDBCRelation(kylin_sales_my1) [numPartitions=1]
      +- SubqueryAlias `t2`
         +- Aggregate [BUYER_ID#52L], [BUYER_ID#52L, sum(price#54) AS ss#62]
            +- SubqueryAlias `kylin_sales_my2`
               +- Project [BUYER_ID#46L AS BUYER_ID#52L, OPS_REGION#47 AS OPS_REGION#53, price#48 AS price#54]
                  +- Relation[BUYER_ID#46L,OPS_REGION#47,price#48] JDBCRelation(kylin_sales_my2) [numPartitions=1]
```

在没有下推功能时，如果想要直接从数据源查询聚合数据，则需要使用 directQuery 功能，如下操作：

```sql
connect jdbc where 
url="jdbc:mysql://localhost:3306/learn_kylin?characterEncoding=utf8"
and driver="com.mysql.jdbc.Driver"
and user="root"
and password="yourpassword"
as db_1;

load jdbc.`db_1.kylin_sales_my1` 
where directQuery='''select BUYER_ID,sum(price) as ss from kylin_sales_my1 where OPS_REGION="Shanghai" group by BUYER_ID''' 
as kylin_sales_my11;

load jdbc.`db_1.kylin_sales_my2` 
where directQuery='''select BUYER_ID,sum(price) as ss from kylin_sales_my2 group by BUYER_ID''' 
as kylin_sales_my22;

select t1.BUYER_ID, t1.ss, t2.ss as s2 from 
t1 join t2 
on t1.BUYER_ID=t2.BUYER_ID 
as output;
```

这种方式虽然能够解决问题，但是在探索式查询时一般查询模式不固定，会对一张表有多次和不同模式的聚合查询，对于每个有聚合操作的查询如果都这么做的话会影响分析师的体验和操作效率。所以如果能够对于指定的数据源开启下推功能的话则可以自动把聚合查询下推到数据源，从而让分析师免去繁复的加载操作。

#### 技术实现

实现聚合下推功能主要思路就是从查询计划中找到可以下推的子树，然后把下推子树转换成对应数据源的 sql 查询语句然后生成新的关系，并替换老的查询子树。(主要思路参考 MoonBox 项目)

主要的处理流程如下：

1. 首先需要使用递归的方式，从叶子结点开始遍历逻辑计划树，给所有的节点打标签，重新构建一颗标签树，内容包括：数据源类型，数据库，能否下压
   1. 判断是否为叶子结点，如果是叶子结点则生成对应的标签，并判断能否下压，
   2. 不是叶子结点的，需要先判断孩子结点是否可以下压，如果可以则判断本结点是否可以下压
   3. 重复以上步骤直到标记整棵树
2. 遍历标签树，挑出所有能够下压的最上层结点。
3. 进行逻辑替换。

对上面的 sql 开启下压功能：

```sql
set enableQueryWithIndexer="true";

connect jdbc where
url="jdbc:mysql://localhost:3306/learn_kylin?characterEncoding=utf8"
and driver="com.mysql.jdbc.Driver"
and user="root"
and password="Hadoop-123"
and ispushdown="true"
as db_1;

load jdbc.`db_1.kylin_sales_my1` as kylin_sales_my1;
load jdbc.`db_1.kylin_sales_my2` as kylin_sales_my2;

select t1.BUYER_ID, t1.ss, t2.ss as s2 from 
(select BUYER_ID,sum(price) as ss from kylin_sales_my1 where OPS_REGION="Shanghai" group by BUYER_ID) t1 
join 
(select BUYER_ID,sum(price) as ss from kylin_sales_my2 group by BUYER_ID) t2 
on t1.BUYER_ID=t2.BUYER_ID 
as output;
```

可以自动生成如下的查询计划：

```
SubqueryAlias `output`
+- Relation[BUYER_ID#97L,ss#126,s2#128] JDBCRelation((SELECT t1.`BUYER_ID`,t1.`ss`,t2.`ss` AS `s2` FROM (SELECT `BUYER_ID`, sum(`price`) AS `ss` FROM kylin_sales_my1 WHERE `OPS_REGION` = 'Shanghai' GROUP BY `BUYER_ID`) t1 INNER JOIN (SELECT `BUYER_ID`, sum(`price`) AS `ss` FROM kylin_sales_my2 GROUP BY `BUYER_ID`) t2 ON t1.`BUYER_ID` = t2.`BUYER_ID`) __SPARK_GEN_JDBC_SUBQUERY_NAME_1) [numPartitions=1]
```

假如只有其中一个表 kylin_sales_my1 开启下推功能，kylin_sales_my2 表不做处理：

```sql
set enableQueryWithIndexer="true";

connect jdbc where
url="jdbc:mysql://localhost:3306/learn_kylin?characterEncoding=utf8"
and driver="com.mysql.jdbc.Driver"
and user="root"
and password="Hadoop-123"
and ispushdown="true"
as db_1;

load jdbc.`db_1.kylin_sales_my1` as kylin_sales_my1;
load jdbc.`db_1.kylin_sales_my2` where ispushdown="false" as kylin_sales_my2;

select t1.BUYER_ID, t1.ss, t2.ss as s2 from 
(select BUYER_ID,sum(price) as ss from kylin_sales_my1 where OPS_REGION="Shanghai" group by BUYER_ID) t1 
join 
(select BUYER_ID,sum(price) as ss from kylin_sales_my2 group by BUYER_ID) t2 
on t1.BUYER_ID=t2.BUYER_ID 
as output;
```

查询计划如下只有 SubqueryAlias t1 进行了下压，SubqueryAlias t2 保持不变 ：

```
SubqueryAlias `output`
+- Project [BUYER_ID#193L, ss#222, ss#223 AS s2#224]
   +- Join Inner, (BUYER_ID#193L = BUYER_ID#213L)
      :- SubqueryAlias `t1`
      :  +- Relation[BUYER_ID#193L,ss#222] JDBCRelation((SELECT `BUYER_ID`, sum(`price`) AS `ss` FROM kylin_sales_my1 WHERE `OPS_REGION` = 'Shanghai' GROUP BY `BUYER_ID`) __SPARK_GEN_JDBC_SUBQUERY_NAME_2) [numPartitions=1]
      +- SubqueryAlias `t2`
         +- Aggregate [BUYER_ID#213L], [BUYER_ID#213L, sum(price#215) AS ss#223]
            +- SubqueryAlias `kylin_sales_my2`
               +- Project [BUYER_ID#207L AS BUYER_ID#213L, OPS_REGION#208 AS OPS_REGION#214, price#209 AS price#215]
                  +- Relation[BUYER_ID#207L,OPS_REGION#208,price#209] JDBCRelation(kylin_sales_my2) [numPartitions=1]
```

#### 未来的优化

目前只是实现了子查询聚合下推功能，也仅仅只是实现了Byzer 和 Kylin 的下推功能。在性能上并没有做性能测试，只是做了一些简单的功能性的测试。所以下推功能依然有很大的优化空间，也有很多功能需要补齐。

具体的方向如下：

1. 增加查询计划的可解释性，比如 查询计划是否改写，改写的部分，改写耗时，下推信息等。
2. 增加测试用例，完善测试流程。
3. 对于不同的数据源，测试和统计下推操作对于查询效率的提升
4. 对于复杂的查询可以处理成子查询模式再进行下压（目前只支持直接子查询下压）
