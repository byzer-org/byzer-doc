## Kolo 如何帮助分析师更高效
### 前言
我之前写过一篇文章叫如何按程序员思维写分析师脚本，这里主要是在两方面帮助分析师：

将程序员一些较为高效的工作模式转移到分析师身上，这包括脚本片段复用，脚本 include，工程项目，视图等。
Kolo 平台提供这些思维的功能支持。
迄今为止，在之前文章提到的所有功能点，都已经在 Kolo 中实现。当然，拥有这些还是远远不够的，因为SQL语言自身的设计和用途上的限制，导致做很多事情还是会有点力有不逮，下部分内容我们会具体举一个例子。

父子关系计算
父子关系计算指的是什么呢？譬如有一张表，数据格式如下：

```json
{"id":0,"parentId":null}
{"id":1,"parentId":null}
{"id":2,"parentId":1}
{"id":3,"parentId":3}
{"id":7,"parentId":0}
{"id":199,"parentId":1}
{"id":200,"parentId":199}
{"id":201,"parentId":199}
```
这里为了简单，我们省略了其他字段，只保留了 id 和 parentId 字段。 一般而言这种结构建模了什么呢？ 我们举个最简单的例子，就是运营的拉新，一般而言现在大家喜欢用拉人头模式，比如如果你邀请其他用户注册，你就能获得奖励，我们会建模这种关系，假设 id 是用户 id，parentId 是邀请该用户注册的用户。

对于后端研发而言，用这种关系表建模该模式是非常有效的。但是对于分析师而言，却有点蛋疼了。比如要实现如下诉求：

1. 计算拉新层级。我想知道任何一个用户它的传播层级有多少。比如 A 拉了 B，B 拉了 C，那么 A 的拉新层级就是 
2. 计算拉新数量。任一用户的拉新用户数（跨层级，也就是子用户的子用户的子用户都算进去）
如果用 SQL 只能用 join 来实现有限层次的计算，而且 SQL 代码会很 ugly，并且计算量还不小。本质上，对于需要递归的计算，SQL 其实不是非常适合的。 那怎么解决呢？

### 扩展 SQL 中的王者：ET
ET 其实是 Kolo 中 Estimator/Transformer 里的缩写，我们借鉴了算法领域的 Estimator/Transformer 的概念，来描述解决一个特定抽象问题的模块。该模块可以使用 Kolo 的扩展语法来完成。 假设我们有一个 ET 解决了父子计算问题，它的名字叫 TreeBuildExt，怎么在SQL中使用呢？

我们来看一个较为完整的示例：

```sql
-- 任何 select SQL 语句本质上都是一个 Transformer，将原数据转化为一个新的形态的数据。这里，我们
-- 从 originalTable 抽取了两个字段，并且将得到的新的 SQL 语句的结果命名为 parentChildTable
select id,parentId from originalTable as parentChildTable;
 
-- 和传统 SQL 语句不通的地方是我们新增了一个 run 关键字，和 select 类似，我们使用 ET TreeBuildExt
-- 对 parentChildTable 进行处理，使用 where 条件语句设置处理他的条件
-- 处理后的结果，我们命名为 result.


run parentChildTable TreeBuildExt.`` 
where idCol="id" and parentIdCol="parentId" and treeType="nodeTreePerRow" 
as result;
 
select * from result as output;
```
最后显示的结果如下：

```shell
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
该 ET 会计算每个元素的层级以及所有子元素。这样分析师只要学会一个类似 select 语句的新 statement，就能用一条语句完成以前很难完成的任务，是不是很酷？

研发可以开发非常多为分析师定制的ET模块，从而高效的提高分析师的工作效率，也让很多”不可能“变成”可能“。值得一提的是，分析师做不了的工作，不需转交给研发，而是由研发开发ET,从而然工作职责更加清晰，让分析师的边界更加宽广。

### 总结
* 关于设置本地开发环境，可参看 [Kolo 开发环境配置指南](https://docs.byzer.org/#/byzer-lang/zh-cn/developer/dev_env/README)。
* 关于 ET 具体开发指南，参看 [Kolo-ET 开发指南](https://docs.byzer.org/#/byzer-lang/zh-cn/extension/et/README)。

如果大家想体验 Kolo 产品，可点击一键体验全套 Kolo 产品，或者自助完成编译部署。