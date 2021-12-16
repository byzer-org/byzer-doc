#  AutoML

AutoML 是将机器学习应用于现实问题的端到端流程自动化的过程。

本次发布的 AutoML 将插件集市的分类算法进行遍历训练的功能，包含 NaiveBayes， LogisticRegression，LinearRegression， RandomForest 以及 GBT 分类算法。AutoML 插件会对用户的输入数据进行多模型训练，然后针对模型表现指标， 进行模型排序，给用户返回表现最优的算法模型。

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

and evaluateTable="data1"
```

