# Byzer 术语表

#### Byzer-lang 

Byzer ，又称为 Byzer-lang，一门面向 Data 和 AI 的低代码、云原生的开源编程语言。

Byzer 是一门结合了声明式编程和命令式编程的**混合编程语言**，其**低代码**且类 SQL 的编程逻辑配合内置算法及插件的加持，能帮助数据工作者们高效**打通数据链路，完成数据的清洗转换，并快速地进行机器学习相关的训练及预测。**

Byzer 希望能够提供**一套语言、一个引擎，就能覆盖整个数据链路，同时可以提供各种算法、模型训练等开箱即用的能力。**

#### ET 

ET是指 转换器（Transformer）与预估器（Estimator）的合称。
> ET 使用的详细介绍和使用请查看 [自定义 ET 插件开发](/byzer-lang/zh-cn/extension/extension/et_dev)

1) 转换器 Transformer

由于在进行模型fit之前，需要先对数据集进行预处理，这里包括对空值的处理、对变量的预处理。可以看作需要对数据集进行一个转换，则这个时候就需要用上 Transformer了。

2) 预估器 Estimator

带有的各种算法模型，无论分类或者回归都属于此类。

#### Byzer Notebook 
Byzer Notebook 是基于 Byzer 引擎搭建的网页交互计算（Web IDE）应用平台。

Byzer Notebook 为业务分析师、数据科学家和 IT 工程师提供了统一的平台和语言，支持交互式地编写和运行代码。并且，在 Byzer Notebook 中，支持多数据源的表进表出和 AI 模型的训练与发布，能够更好地帮助用户打通复杂的数据链路，实现低成本的数据分析和 AI 落地。

#### UDF/UDAF 函数
UDF：User-Defined-Function 用户自定义函数

UDAF：User- Defined Aggregation Funcation 用户自定义聚合函数 

在 Byzer 中，UDF/UDAF 函数可以直接应用于 select 语句，对查询结构做格式化处理后，再输出内容。

#### Byzer-Python

Byzer-lang 拥抱 python 生态，python 语言可以通过特定的配置方式，与 Byzer 语言进行无缝对接与扩展。这种高阶的集成应用方式，我们称之为 Byzer-Python。


