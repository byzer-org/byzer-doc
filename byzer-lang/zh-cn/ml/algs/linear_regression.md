# LinearRegression

线性回归(Linear Regression)是利用称为线性回归方程的最小二乘函数对一个或多个自变量和因变量之间关系进行建模的一种回归分析

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
-- -- use LinearRegression
train data1 as LinearRegression.`/tmp/model_3` where

-- -- once set true,every time you run this script, MLSQL will generate new directory for you model
keepVersion="true" 

-- specicy the test dataset which will be used to feed evaluator to generate some metrics e.g. F1, Accurate
and evaluateTable="data1"

-- specify group 0 parameters
and `fitParam.0.labelCol`="label"
and `fitParam.0.featuresCol`="features"
and `fitParam.0.elasticNetParam`="0.1"

-- specify group 1 parameters
and `fitParam.1.featuresCol`="features"
and `fitParam.1.labelCol`="label"
and `fitParam.1.elasticNetParam`="0.8"
;
```

最后输出结果如下：

```
name   value
---------------	------------------
modelPath	/_model_4/model/1
algIndex	1
alg	        org.apache.spark.ml.regression.LinearRegression
metrics	    f1: 0.0 weightedPrecision: 0.0 weightedRecall: 0.0 accuracy: 0.0
status	    success
message	
startTime	20210824 52:14:52:441
endTime	    20210824 52:14:53:429
trainParams	Map(labelCol -> label, featuresCol -> features, elasticNetParam -> 0.8)
---------------------------------
modelPath	/_model_4/model/0
algIndex	0
alg	        org.apache.spark.ml.regression.LinearRegression
metrics	    f1: 0.0 weightedPrecision: 0.0 weightedRecall: 0.0 accuracy: 0.0
status	    success
message	
startTime	20210824 52:14:53:429
endTime	    20210824 52:14:54:228
trainParams	Map(featuresCol -> features, elasticNetParam -> 0.1, labelCol -> label)
```

对于大部分内置算法而言，都支持如下几个特性：

1. 可以通过keepVersion 来设置是否保留版本。
2. 通过fitParam.数字序号 配置多组参数，设置evaluateTable后系统自动算出metrics.


## 批量预测

```
predict data1 as LinearRegression.`/tmp/model_3`;
```

结果如下：

```
features	                            label	prediction
{"type":1,"values":[5.1,3.5,1.4,0.2]}	0	0.24999999999999645
{"type":1,"values":[5.1,3.5,1.4,0.2]}	1	0.24999999999999645
```

## API预测


```sql
register LinearRegression.`/tmp/model_3` as lr_predict;

-- you can specify which module you want to use:
register LinearRegression.`/tmp/model_3` as lr_predict where
algIndex="0";

-- you can specify which metric the MLSQL should use to get best model
register LinearRegression.`/tmp/model_3` as lr_predict where
autoSelectByMetric="f1";

select lr_predict(features) as predict_label, label from data1 as output;
```

algIndex可以选择我用哪组参数得到的算法。我们也可以让系统自动选择，前提是我们在训练时配置了evalateTable， 这个只要使用autoSelectByMetric即可。
最后，就可以像使用一个函数一样对一个feature进行预测了。