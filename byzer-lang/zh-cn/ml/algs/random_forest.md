# 随机森林/RandomForest

RandomForest  随机森林是利用多个决策树对样本进行训练、分类并预测的一种分类算法，主要应用于回归和分类场景。在对数据进行分类的同时，还可以给出各个变量的重要性评分，评估各个变量在分类中所起的作用。

```sql
-- 创建测试数据集
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

-- 使用随机森林算法进行训练
train data1 as RandomForest.`/tmp/model` where

-- 如果参数 keepVersion 设置成 true，以后每次运行脚本，Byzer 都会为你的模型保存一个最新的版本
keepVersion="true" 

-- 用参数 evaluateTable 指明验证集，它将被用来给评估器提供一些评价指标，如：F1、准确度等
and evaluateTable="data1"

-- 指明参数组0（即：第一组参数组）的参数
and `fitParam.0.featuresCol`="features"
and `fitParam.0.labelCol`="label"
and `fitParam.0.maxDepth`="2"

-- 指明参数组1（即：第二组参数组）的参数
and `fitParam.1.featuresCol`="features"
and `fitParam.1.labelCol`="label"
and `fitParam.1.maxDepth`="10"
;
```

最后输出结果如下：

```
name   value
---------------------------------
modelPath    /tmp/model/_model_10/model/1
algIndex     1
alg          org.apache.spark.ml.classification.RandomForestClassifier
metrics      f1: 0.7625000000000001 weightedPrecision: 0.8444444444444446 weightedRecall: 0.7999999999999999 accuracy: 0.8
status       success
startTime    20180913 59:15:32:685
endTime      20180913 59:15:36:317
trainParams  Map(maxDepth -> 10)
---------------------------------
modelPath    /tmp/model/_model_10/model/0
algIndex     0
alg          org.apache.spark.ml.classification.RandomForestClassifier
metrics      f1:0.7625000000000001 weightedPrecision: 0.8444444444444446 weightedRecall: 0.7999999999999999 accuracy: 0.8
status       success
startTime    20180913 59:1536:318
endTime      20180913 59:1538:024
trainParams  Map(maxDepth -> 2, featuresCol -> features, labelCol -> label)
```

对于大部分内置算法而言，都支持如下几个特性：

1. 可以通过 `keepVersion` 来设置是否保留版本。
2. 通过 `fitParam.数字序号` 配置多组参数，设置 `evaluateTable` 后系统自动算出 metrics.


### 批量预测

```
predict data1 as RandomForest.`/tmp/model`;
```

结果如下：

```
features                                label  rawPrediction                                            probability  prediction
{"type":1,"values":[5.1,3.5,1.4,0.2]}	0	{"type":1,"values":[16.28594461094461,3.7140553890553893]}	{"type":1,"values":[0.8142972305472306,0.18570276945276948]}	0
{"type":1,"values":[5.1,3.5,1.4,0.2]}	1	{"type":1,"values":[16.28594461094461,3.7140553890553893]}	{"type":1,"values":[0.8142972305472306,0.18570276945276948]}	0
```

### API预测


```sql
register RandomForest.`/tmp/model` as rf_predict;

-- 参数 algIndex 你可以指明用哪一组参数训练出的模型
register RandomForest.`/tmp/model` as rf_predict where
algIndex="0";

-- 参数 autoSelectByMetric 可以用来指明用那个指标来判断最优模型,此处选择 F1
register RandomForest.`/tmp/model` as rf_predict where
autoSelectByMetric="f1";

select rf_predict(features) as predict_label, label from data1 as output;
```

- 参数`algIndex` 可以让用户指定用哪组参数得到算法模型。
- 当然用户也可以让系统自动选择，前提是在训练时配置了参数`evalateTable` 预先评估模型的表现情况， 然后使用参数 `autoSelectByMetric` 指定判定指标即可选出最优算法模型。
- 最后，就可以像使用一个函数一样对一个 feature 进行预测了。