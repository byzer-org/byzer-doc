# 常见问题FAQ

## 基本概念与问答

### Q1.1: Byzer 语法可以正常写 SQL 吗？

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


### Q1.2: MLSQL，Byzer 和 Byzer Notebook 三者的关系

Byzer 社区的前身是 MLSQL 社区，Byzer 将秉持 MLSQL 低成本落地 Data + AI 的技术初衷，并融合更加开放且多元的语言及产品能力，打造更加完善的新一代开源语言生态。

Byzer 是一个开源的项目, 将会包含 Notebook, 可视化 Workflow, Byzer 引擎, Byzer 插件, Byzer 桌面版等一些列产品的集合。

Byzer Notebook 是基于 Byzer 引擎搭建的**网页交互计算（Web IDE）应用平台**，提供易用而又完善的产品能力。

Byzer Notebook 为 Byzer 定制化，可以最大程度可以发挥 Byzer 语言的特性。Byzer 和 Byzer Notebook 的关系就像 Jupyter 和 python 的关系一样。

### Q1.3: 为什么说 Byzer 语言是可编程的 SQL 语言？

Byzer 语法非常像 SQL，可以理解为是以 SQL 语法打底的一个新语言。我们在原生 SQL 语法的基础上提供了非常强大的可编程能力，这主要体现在我们可以像传统编程语言一样组织 Byzer 代码，这包括：
- 命令行支持
- 脚本化
- 支持引用
- 支持第三方模块
- 支持模板
- 支持函数定义
- 支持分支语句
所以和 SQL 相比，我们可以理解为 Byzer 是一个可编程的 SQL。

### Q1.4：Byzer Notebook 和其他的 Notebook 产品相比，优势在哪里？

**1. Byzer Notebook: Notebook but more than Notebook.**

支持可视化 Workflow 的运行和调度功能的集成，可以做到单平台、低代码流程化管理端到端的数据链路。

**2. 通用产品 VS 专用产品**

集成引擎通用产品，往往会损失掉部分特性和能力。Byzer Notebook 为 Byzer 语言定制化，可以最大程度可以发挥 Byzer 语言的特点。

**3. Byzer Notebook 可以做到SQL 和 Python 代码的无缝衔接**

Python 是作为寄生语言存在于 Byzer 当中。Byzer 通过 pyjava 库，让 Python 脚本可以访问到 Byzer 产生的临时表，也可以让 Byzer 宿主语言获取 Python 的结果。

并且，正因为数据源导入和中间表在 Byzer 语言的数据流转中都可以被存为一张虚拟表，在 Notebook中，上一个 Cell 中用 SQL 处理完的结果集可以直接被下一个 Cel l中的 Python 脚本调用，无需实际的数据落地就可以串联数据链路，极大地提高了效率。

**4.Byzer Notebook 底层是基于 Spark 和 Ray 的混合引擎**
- Byzer 引擎是基于 Spark 搭建的，因此是一个天然支持分布式的语言。
- 另外，Ray 可插拔，集群可以指定。Ray 使用了和传统分布式计算系统不一样的架构和对分布式计算的抽象方式，具有比 Spark 更优异的计算性能，对 GPU 对感知能力和分布式编程能力超越 Spark。


### Q1.5：Byzer Notebook 是 Byzer 唯一的产品形态吗？

Byzer Notebook 是现在 Byzer 项目主推的一种产品形态，也是开源给社区的产品形态。我们已经在Byzer Notebook 里集成了基本的可视化 workflow 能力，后续还会集成脚本商店，扩展 workflow 能力以及其他的产品能力。
除了 Notebook 形态，还有我们提供了 vscode 插件的 desktop 版本，用户也可以在 vscode 里进行编码。
当然用户也可以基于 Byzer-lang 做各种新产品，比如针对产品和运营的自助分析产品，流式计算产品，包装成数据中台/AI中台等，只要在前端生成对应的 Byzer-lang 语句就可以交给引擎执行，而无需关注其他细节。

## 产品功能相关

### Q2.1 Byzer Notebook 是如何提供 Notebook 能力 和 ETL 能力的？

- **Notebook**

Byzer 目前已经拥有相对成熟的Notebook 交互界面，具体参考如下图：

<p align="center">
    <img src="/byzer-notebook/zh-cn/appendix/images/mainpage.png" alt="name"  width="800"/>
</p>

- **Workflow**

Byzer Notebook 将 Byzer 提供的 ET 能力 按照类别和功能拆分成了不同的节点，并在画布上根据Input/Output 串行或者并行地显示数据处理的工作流。
同时，Byzer Notebook 也支持 Workflow 一键转码 Notebook，并支持二次编辑，省去了复杂的编码过程。

<p align="center">
    <img src="/byzer-notebook/zh-cn/appendix/images/workflow.png" alt="name"  width="800"/>
</p>

### Q2.2: Byzer Notebook 是否支持语法提示和代码的高亮

Byzer **语法提示** 和 **代码高亮** 的功能都具备。

<p align="center">
    <img src="/byzer-notebook/zh-cn/appendix/images/codehint.png" alt="name"  width="800"/>
</p>

> 代码提示教学视频 refer：
https://www.bilibili.com/video/BV1V54y1U7kz?spm_id_from=333.999.0.0


### Q2.3：Byzer Notebook 如何进行可视化展示，怎么在分析过程中看图、看数据？数据量很大的情况下，如何展示？
在 Byzer notebook 或 Byzer-lang 桌面版(vscode) 都能够实现复杂的 png，html 格式的图表。 

其中 png 主要是静态图， html 等则主要是动态图表（甚至有一定交互性）。

用户可以随时随地使用 Python 的图表库进行图标的绘制。比如下面图片就是使用 Byzer Notebook 绘制的：

<p align="center">
    <img src="/byzer-notebook/zh-cn/appendix/images/view.png" alt="name"  width="800"/>
</p>


**具体代码如下:**

首先是数据处理：

```SQL
select int(`id`), (case when `diagnosis` = 'M' then 1 else 0 end) as `diagnosis`,float(`radius_mean`),float(`texture_mean`),

float(`perimeter_mean`),float(`area_mean`),float(`smoothness_mean`),

float(`compactness_mean`),float(`concavity_mean`),float(`concave points_mean`),

float(`symmetry_mean`),float(`fractal_dimension_mean`),float(`radius_se`),float(`texture_se`),

float(`perimeter_se`),float(`area_se`),float(`smoothness_se`),float(`compactness_se`),float(`concavity_se`),

float(`concave points_se`),float(`symmetry_se`),float(`fractal_dimension_se`),float(`radius_worst`),float(`texture_worst`),

float(`perimeter_worst`),float(`area_worst`),float(`smoothness_worst`),float(`compactness_worst`),float(`concavity_worst`),

float(`concave points_worst`),float(`symmetry_worst`),float(`fractal_dimension_worst`)

from data as data1;
```


接着是绘图代码：

```python
#%env=source /usr/local/Caskroom/miniconda/base/bin/activate dev2

#%python

#%input=data1

#%schema=st(field(content,string),field(mime,string))

from pyjava.api.mlsql import RayContext,PythonContext

import pandas as pd

from pyecharts import options as opts

from pyecharts.charts import Line

import os

import matplotlib.pyplot as plt

import seaborn as sns

from pyjava.api import Utils

# 这句是为了代码提示

context:PythonContext = context

ray_context = RayContext.connect(globals(),None)

data = ray_context.to_pandas()

plt.figure(figsize = (20, 15))

sns.set(style="darkgrid")

plotnumber = 1

for column in data:

    if plotnumber <= 30:

        ax = plt.subplot(5, 6, plotnumber)

        sns.histplot(data[column],kde=True)

        plt.xlabel(column)

    plotnumber += 1

# plt.show()
Utils.show_plt(plt,context)
```

只要输出格式符合`st(field(content,string),field(mime,string))` 系统就会自动按图表方式展示。



对于数据集很大，实际要传递给图的数据并不会很多，此时你可以：

1. 使用 SQL 进行聚合，聚合后的结果传递给绘图的 Python 代码
2. 使用 Ray，将大表转化为 Dask，然后提供给绘图的代码。



将数据转化为分布式 Dask（分布式 Pandas）数据集在 Byzer-python 里只需要一行代码：

```python
## 将指定表的数据转化为分布式 pandas (dask)
data = ray_context.to_dataset().to_dask()
```
### Q2.4：Byzer notebook 中的参数说明功能是否齐全？

从语言角度来讲， Byzer-lang 是支持自解释的。举个例子，以数据源为例，我想知道系统支持哪些数据源，每个数据源都有哪些参数，这些可以通过 宏函数 来进行查看。

<p align="center">
    <img src="/byzer-notebook/zh-cn/appendix/images/showfunc1.png" alt="name"  width="600"/>
</p>

<p align="center">
    <img src="/byzer-notebook/zh-cn/appendix/images/showfunc2.png" alt="name"  width="600"/>
</p>

对于ET 还可以查看文档和代码示例等：
<p align="center">
    <img src="/byzer-notebook/zh-cn/appendix/images/showfunc3.png" alt="name"  width="600"/>
</p>


