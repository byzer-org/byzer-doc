#  自动机器学习 AutoML

AutoML 是将机器学习应用于现实问题的端到端流程自动化的过程。

AutoML 可以提供将分类算法进行遍历训练的功能，这些算法包含 NaiveBayes， LogisticRegression，LinearRegression， RandomForest 以及 GBT 分类算法。AutoML 插件会对用户的输入数据进行多模型训练，然后针对模型表现指标， 进行模型排序，给用户返回表现最优的算法模型。

```sql
-- create test data
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

train data1 as AutoML.`/tmp/auto_ml` where

-- if the param 'algos' is not setted, the data will be trained among GBTs,LinearRegression,LogisticRegression,NaiveBayes,RandomForest 

algos="LogisticRegression,NaiveBayes" 

-- once set true,every time you run this script, MLSQL will generate new directory for you model

and keepVersion="true" 

-- specicy the test dataset which will be used to feed evaluator to generate some metrics e.g. F1, Accurate

and evaluateTable="data1";
```

最后输出结果如下：

<p align="center">
    <img src="/byzer-lang/zh-cn/ml/algs/images/automl_result.png" alt="name"  width="800"/>
</p>

**AutoML支持如下几个特性：** 

- 可以通过 keepVersion 来设置是否保留版本。
- AutoML 支持在用户指定的算法集合里进行模型训练，用户通过配置 algos 参数（目前支持 " GBTs, LinearRegression, LogisticRegression, NaiveBayes, RandomForest " 的子集），让数据集在指定的算法集合中进行训练，获取最优模型
- AutoML 会根据算法的表现排序，默认是按照 **accuracy**，用户可以指定按照 f1 或者其他的 metrics 进行排序。
- AutoML 预测的时候，会根据历史训练的所有模型中挑选出**表现最好的模型**进行打分预测，用户无需指定特定模型。


### 批量预测

```sql
predict data1 as AutoML.`/tmp/auto_ml`;
```

结果如下：
<p align="center">
    <img src="/byzer-lang/zh-cn/ml/algs/images/batchautoml.png" alt="name"  width="800"/>
</p>


