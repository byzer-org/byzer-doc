#  Logistic Regression

Logistic Regression 一种广义的线性回归分析模型，常用于数据挖掘，疾病自动诊断，经济预测等领域。

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
select vec_dense(features) as features , label as label from data
as data1;

-- select * from data1 as output1;
-- -- use LogisticRegression
train data1 as LogisticRegression.`/tmp/model_2` where

-- -- once set true,every time you run this script, MLSQL will generate new directory for you model
keepVersion="true" 

-- specicy the test dataset which will be used to feed evaluator to generate some metrics e.g. F1, Accurate
and evaluateTable="data1"

-- specify group 0 parameters
and `fitParam.0.labelCol`="label"
and `fitParam.0.featuresCol`="features"
and `fitParam.0.fitIntercept`="true"

-- specify group 1 parameters
and `fitParam.1.featuresCol`="features"
and `fitParam.1.labelCol`="label"
and `fitParam.1.fitIntercept`="false"
;
```

最后输出结果如下：

```
name        value
---------------	------------------
modelPath	/_model_5/model/1
algIndex	1
alg	        org.apache.spark.ml.classification.LogisticRegression
metrics	    f1: 0.7625000000000001 weightedPrecision: 0.8444444444444446 weightedRecall: 0.7999999999999999 accuracy: 0.8
status	    success
message	
startTime	20210824 42:14:33:761
endTime	    20210824 42:14:41:984
trainParams	Map(labelCol -> label, featuresCol -> features, fitIntercept -> false)
---------------	------------------
modelPath	/_model_5/model/0
algIndex	0
alg	        org.apache.spark.ml.classification.LogisticRegression
metrics	    f1: 0.7625000000000001 weightedPrecision: 0.8444444444444446 weightedRecall: 0.7999999999999999 accuracy: 0.8
status	    success
message	
startTime	20210824 42:14:41:985
endTime	    20210824 42:14:47:830
trainParams	Map(featuresCol -> features, labelCol -> label, fitIntercept -> true)
```

对于大部分内置算法而言，都支持如下几个特性：

1. 可以通过 keepVersion 来设置是否保留版本。
2. 通过 fitParam.数字序号 配置多组参数，设置 evaluateTable 后系统自动算出 metrics.


### 批量预测

```
predict data1 as LogisticRegression.`/tmp/model`;
```

结果如下：

```
features	                            label	        rawPrediction	                                    probability	                                                    prediction
{"type":1,"values":[5.1,3.5,1.4,0.2]}	0	{"type":1,"values":[1.0986123051777668,-1.0986123051777668]}	{"type":1,"values":[0.7500000030955607,0.24999999690443933]}	0
{"type":1,"values":[5.1,3.5,1.4,0.2]}	1	{"type":1,"values":[1.0986123051777668,-1.0986123051777668]}	{"type":1,"values":[0.7500000030955607,0.24999999690443933]}	0
```

### API预测


```sql
register LogisticRegression.`/tmp/model_2` as lr_predict;

-- you can specify which module you want to use:
register LogisticRegression.`/tmp/model_2` as lr_predict where
algIndex="0";

-- you can specify which metric the MLSQL should use to get best model
register LogisticRegression.`/tmp/model_2` as lr_predict where
autoSelectByMetric="f1";

select lr_predict(features) as predict_label, label from data1 as output;
```

algIndex可以选择我用哪组参数得到的算法。我们也可以让系统自动选择，前提是我们在训练时配置了evaluateTable， 这个只要使用autoSelectByMetric即可。
最后，就可以像使用一个函数一样对一个feature进行预测了。
