# 朴素贝叶斯算法/NaiveBayes

NaiveBayes 是一种分类算法。和决策树模型相比，朴素贝叶斯分类器(Naive Bayes Classifier 或 NBC)发源于古典数学理论，有着坚实的数学基础，以及稳定的分类效率。同时，NBC模型所需估计的参数很少，对缺失数据不太敏感，算法也比较简单。

```sql
-- 创建测试数据
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

-- 用朴素贝叶斯训练数据
train data1 as NaiveBayes.`/tmp/model` where

-- 如果参数 keepVersion 设置成 true，以后每次运行脚本，Byzer 都会为你的模型保存一个最新的版本
keepVersion="true" 

--  用参数 evaluateTable 指明验证集，它将被用来给评估器提供一些评价指标，如：F1、准确度等
and evaluateTable="data1"

-- 指明参数组0（即：第一组参数组） 的参数
and `fitParam.0.featuresCol`="features"
and `fitParam.0.labelCol`="label"
and `fitParam.0.smoothing`="0.5"

-- 指明参数组1（即：第二组参数组）的参数
and `fitParam.1.featuresCol`="features"
and `fitParam.1.labelCol`="label"
and `fitParam.1.smoothing`="0.2"
;
```

最后输出结果如下：

```
name   value
---------------------------------
modelPath    /tmp/model/_model_10/model/1
algIndex     1
alg          org.apache.spark.ml.classification.NaiveBayes
metrics      f1: 0.7625000000000001 weightedPrecision: 0.8444444444444446 weightedRecall: 0.7999999999999999 accuracy: 0.8
status       success
startTime    20180913 59:15:32:685
endTime      20180913 59:15:36:317
trainParams  Map(smoothing -> 0.2,featuresCol -> features, labelCol -> label)
---------------------------------
modelPath    /tmp/model/_model_10/model/0
algIndex     0
alg          org.apache.spark.ml.classification.NaiveBayes
metrics      f1:0.7625000000000001 weightedPrecision: 0.8444444444444446 weightedRecall: 0.7999999999999999 accuracy: 0.8
status       success
startTime    20180913 59:1536:318
endTime      20180913 59:1538:024
trainParams  Map(smoothing -> 0.2, featuresCol -> features, labelCol -> label)
```

对于大部分内置算法而言，都支持如下几个特性：

1. 可以通过 `keepVersion` 来设置是否保留版本。
2. 通过 `fitParam. 数字序号` 配置多组参数，设置` evaluateTable` 后系统自动算出 metrics.


### 批量预测

```
predict data1 as NaiveBayes.`/tmp/model`;
```

结果如下：

```
features                                label  rawPrediction                                            probability  prediction
{"type":1,"values":[5.1,3.5,1.4,0.2]}	0	{"type":1,"values":[16.28594461094461,3.7140553890553893]}	{"type":1,"values":[0.8142972305472306,0.18570276945276948]}	0
{"type":1,"values":[5.1,3.5,1.4,0.2]}	1	{"type":1,"values":[16.28594461094461,3.7140553890553893]}	{"type":1,"values":[0.8142972305472306,0.18570276945276948]}	0
```

###  API 预测


```sql
register NaiveBayes.`/tmp/model` as rf_predict;

-- 参数 algIndex 你可以指明用哪一组参数训练出的模型
register NaiveBayes.`/tmp/model` as rf_predict where
algIndex="0";

-- 参数 autoSelectByMetric 可以用来指明用那个指标来判断最优模型
register NaiveBayes.`/tmp/model` as rf_predict where
autoSelectByMetric="f1";

select rf_predict(features) as predict_label, label from data1 as output;
```

- 参数`algIndex` 可以让用户指定用哪组参数得到算法模型。
- 当然用户也可以让系统自动选择，前提是在训练时配置了参数`evalateTable` 预先评估模型的表现情况， 然后使用参数 `autoSelectByMetric` 指定判定指标即可选出最优算法模型。
- 最后，就可以像使用一个函数一样对一个 feature 进行预测了。