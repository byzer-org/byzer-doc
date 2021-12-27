# 常见问题FAQ

### Q1: Byzer 语法可以正常写 SQL 吗？

A1: Byzer 兼容的是 spark SQL，但特殊的是 Byzer 里所有的输入输出都是一张虚拟表的概念，需要虚拟表承接。和正常的 SQL 对比起来，Byzer 则需要将结果用 as 语句保存成一张新的 Output 表，就可以在接下来的数据处理进程中进行调用。例如：

**正常的 SQL 语句：**

``` sql
SELECT
b.* 
FROM
 table_a as a
 LEFT JOIN table_b as b 
 ON a.id = b.id 
WHERE
 a.study_id in( '12345678' )
 AND a.status <> 3 
 AND b.use_status = 0；
```

**Byzer 语法：**

```sql
SELECT
b.* 
FROM
 table_a as a
 LEFT JOIN table_b as b 
 ON a.id = b.id 
WHERE
 a.study_id in( '12345678' )
 AND a.status <> 3 
 AND b.use_status = 0 as new_table;
 
 select * from new_table as traindata;
```


### Q2: MLSQL，Byzer 和 Byzer Notebook 三者的关系

Byzer社区 的前身是 MLSQL 社区，Byzer 将秉持 MLSQL 低成本落地 Data + AI 的技术初衷，并融合更加开放且多元的语言及产品能力，打造更加完善的新一代开源语言生态。

Byzer 是一个开源的项目, 将会包含 Notebook, 可视化 Workflow, Byzer 引擎, Byzer 插件, Byzer 桌面版等一些列产品的集合。Byzer Notebook 则是基于 Byzer 引擎搭建的网页交互计算（Web IDE）应用平台。Byzer 和 Byzer Notebook 的关系就像 Python 和 Jupyter 的关系一样。

### Q3: 为什么说 Byzer 语言是可编程的 SQL 语言？

Byzer 语法非常像 SQL，可以理解为是以 SQL 语法打底的一个新语言。我们在原生 SQL 语法的基础上提供了非常强大的可编程能力，这主要体现在我们可以像传统编程语言一样组织 Byzer 代码，这包括：
- 命令行支持
- 脚本化
- 支持引用
- 支持第三方模块
- 支持模板
- 支持函数定义
- 支持分支语句
所以和 SQL 相比，我们可以理解为 Byzer 是一个可编程的 SQL。

### Q4：Byzer Notebook 和其他的 Notebook 产品相比，优势在哪里？

**1. Byzer Notebook: Notebook but more than Notebook.**

支持可视化 Workflow 的运行和调度功能的集成，可以做到单平台、低代码流程化管理端到端的数据链路。

**2. 通用产品 VS 专用产品**

集成引擎通用产品，往往会损失掉部分特性和能力。Byzer Notebook为 Byzer 语言定制化，可以最大程度可以发挥 Byzer 语言的特点。

**3. Byzer Notebook 可以做到SQL 和 Python 代码的无缝衔接**

Python 是作为寄生语言存在于 Byzer 当中。Byzer 通过 pyjava 库，让 Python 脚本可以访问到 Byzer 产生的临时表，也可以让 Byzer 宿主语言获取 Python 的结果。

并且，正因为数据源导入和中间表在 Byzer 语言的数据流转中都可以被存为一张虚拟表，在 Notebook中，上一个 Cell 中用 SQL 处理完的结果集可以直接被下一个 Cel l中的 Python 脚本调用，无需实际的数据落地就可以串联数据链路，极大地提高了效率。

**4.Byzer Notebook 底层是基于 Spark 和 Ray 的混合引擎**
- Byzer 引擎是基于Spark搭建的，因此是一个天然支持分布式的语言。
- 另外，Ray 可插拔，集群可以指定。Ray 使用了和传统分布式计算系统不一样的架构和对分布式计算的抽象方式，具有比Spark更优异的计算性能，对 GPU 对感知能力和分布式编程能力超越 Spark。
