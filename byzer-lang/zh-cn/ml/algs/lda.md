# 隐含狄利克雷分布/LDA

在机器学习领域，LDA 是两个常用模型的简称：**Linear Discriminant Analysis** 和 **Latent Dirichlet Allocation**。本章节中的 LDA 仅指代 Latent Dirichlet Allocation. **LDA 在主题模型中占有非常重要的地位，常用来文本分类。**

LDA由Blei, David M.、Ng, Andrew Y.、Jordan于2003年提出，用来推测文档的主题分布。它可以将文档集中每篇文档的主题以概率分布的形式给出，从而通过分析一些文档抽取出它们的主题分布后，便可以根据主题分布进行主题聚类或文本分类。

下面看看如何使用：

```sql
set jsonStr='''
{"features":[5.1,3.5,1.4,0.2],"label":0.0},
{"features":[5.1,3.5,1.4,0.2],"label":1.0}
{"features":[5.1,3.5,1.4,0.2],"label":0.0}
{"features":[4.4,2.9,1.4,0.2],"label":0.0}
{"features":[5.1,3.5,1.4,0.2],"label":1.0}
{"features":[5.1,3.5,1.4,0.2],"label":0.0}
{"features":[5.1,3.5,1.4,0.2],"label":0.0}
{"features":[4.7,3.2,1.3,0.2],"label":1.0}
{"features":[5.1,3.5,1.4,0.2],"label":0.0}
{"features":[5.1,3.5,1.4,0.2],"label":0.0}
''';
load jsonStr.`jsonStr` as data;
select vec_dense(features) as features ,label as label from data
as data1;

```

```sql
train data1 as LDA.`/tmp/model` where

-- k: number of topics, or number of clustering centers
k="3"

-- docConcentration: the hyperparameter (Dirichlet distribution parameter) of article distribution must be >1.0. The larger the value is, the smoother the predicted distribution is
and docConcentration="3.0"

-- topictemperature: the hyperparameter (Dirichlet distribution parameter) of the theme distribution must be >1.0. The larger the value is, the more smooth the distribution can be inferred
and topicConcentration="3.0"

-- maxIterations: number of iterations, which need to be fully iterated, at least 20 times or more
and maxIter="100"

-- setSeed: random seed
and seed="10"

-- checkpointInterval: interval of checkpoints during iteration calculation
and checkpointInterval="10"

-- optimizer: optimized calculation method currently supports "em" and "online". Em method takes up more memory, and multiple iterations of memory may not be enough to throw a stack exception
and optimizer="online"
;
```

上面大部分参数都不需要配置。训练完成后会返回状态如下：

<p align="center">
    <img src="/byzer-lang/zh-cn/ml/algs/images/LDAresult.png" alt="name"  width="800"/>
</p>

### 批量预测

```sql
predict data1 as LDA.`/tmp/model` ;
```

结果如下：

<p align="center">
    <img src="/byzer-lang/zh-cn/ml/algs/images/LDAresult2.png" alt="name"  width="800"/>
</p>


### API预测

> 目前只支持spark 2.3.x

```sql
register LDA.`/tmp/model` as lda;
select label,lda(4) topicsMatrix,lda_doc(features) TopicDistribution,lda_topic(label,4) describeTopics from data as result;
```



同样的当你注册 LDA 函数事，会给隐式生成多个函数:

1. lda 接受一个词
2. lda_doc 接受一个文档
3. lda_topic 接受一个主题，以及显示多少词
