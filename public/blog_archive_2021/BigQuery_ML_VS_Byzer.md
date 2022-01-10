# 谷歌 BigQuery ML VS Byzer

### 前言
对比下[谷歌 BigQuery ML正式上岗，只会用 SQL 也能玩转机器学习！](https://mp.weixin.qq.com/s/4mZjdFL68V_OXKCkZ72KrQ)和 Byzer 这两款产品。

### StreamingPro 简介
StreamingPro 是一套基于Spark的数据平台，Byzer 是基于 StreamingPro 的算法平台。利用 Byzer，你可以用类似 SQL 的方式完成数据的 ETL，算法训练，模型部署等一整套 ML Pipline。Byzer 融合了数据平台和算法平台，可以让你在一个平台上把这些事情都搞定。

### 运行方式
Byzer 支持 Run as Application 和 Run as Service。Byzer Run as Service 很简单，你可以直接在自己电脑上体验： Five Minute Quick Tutorial
BigQuery ML 则是云端产品，从表象上来看，应该也是 Run As Service。

### 语法功能使用
BigQuery ML 训练一个算法的方式为：

```sql
CREATE OR REPLACE MODEL flights.arrdelay
OPTIONS
 (model_type='linear_reg', labels=['arr_delay']) AS
SELECT
 arr_delay,
 carrier,
 origin,
 dest,
 dep_delay,
 taxi_out,
 distance
FROM
 `cloud-training-demos.flights.tzcorr`
WHERE
 arr_delay IS NOT NULL
```
 
BigQuery ML 也对原有的 SQL 语法做了增强，添加了新的关键之，但是总体是遵循 SQL 原有语法形态的。

完成相同功能，在 Byzer 中的做法如下：

```sql
select arr_delay, carrier, origin, dest, dep_delay,
taxi_out, distance from db.table 
as lrCorpus;
 
train lrCorpus as LogisticRegressor.`/tmp/linear_regression_model`
where inputCol="features"
and labelCol="label"
;
```

同样的，Byzer 也对 SQL 进行扩展和变更，就模型训练而言，改变会更大些。对应的，训练完成后，你可以 load 数据查看效果，结果类似这样：

```
+--------------------+--------+--------------------+-------------------+-------+-------------+-------------+--------------------+
|           modelPath|algIndex|                 alg|              score| status|    startTime|      endTime|         trainParams|
+--------------------+--------+--------------------+-------------------+-------+-------------+-------------+--------------------+
|/tmp/william/tmp/...|       1|org.apache.spark....|-1.9704115113779945|success|1532659750073|1532659757320|Map(ratingCol -> ...|
|/tmp/william/tmp/...|       0|org.apache.spark....|-1.8446490919033698|success|1532659757327|1532659760394|Map(ratingCol -> ...|
+--------------------+--------+--------------------+-------------------+-------+-------------+-------------+--------------------+
```
在预测方面，BigQuery ML 语法如下：

```sql
SELECT * FROM ML.PREDICT(MODEL flights.arrdelay,
(
SELECT
 carrier,
 origin,
 dest,
 dep_delay,
 taxi_out,
 distance,
 arr_delay AS actual_arr_delay
FROM
 `cloud-training-demos.flights.tzcorr`
WHERE
 arr_delay IS NOT NULL
LIMIT 10))
```

ML 指定模型名称就可以调用对应的预测函数。在 Byzer 里，则需要分两步：

先注册模型，这样就能得到一个函数（pa_lr_predict），名字你自己定义。

```sql
register LogisticRegressor.`/tmp/linear_regression_model` as pa_lr_predict options
modelVersion="1" ;
```

接着就可以使用了：

```sql
select pa_lr_predict(features) from lrCorpus limit 10 as predict_result;
```

### 和数据平台集成
BigQuery ML 也支持利用 SQL 对数据做复杂处理，因此可以很好的给模型准备数据。Byzer 也支持非常复杂的数据处理。

### 除了算法以外
#### “数据处理模型”以及 SQL 函数
值得一提的是，Byzer 提供了非常多的“数据处理模型”以及 SQL 函数。比如我要把文本数据转化为 tfidf，一条指令即可：

```sql
-- 把文本字段转化为tf/idf向量，可以自定义词典
train orginal_text_corpus as TfIdfInPlace.`/tmp/tfidfinplace`
where inputCol="content"
-- 分词相关配置
and ignoreNature="true"
and dicPaths="...."
-- 停用词路径
and stopWordPath="/tmp/tfidf/stopwords"
-- 高权重词路径
and priorityDicPath="/tmp/tfidf/prioritywords"
-- 高权重词加权倍数
and priority="5.0"
-- ngram 配置
and nGram="2,3"
-- split 配置，以split为分隔符分词，
and split=""
;
 
-- lwys_corpus_with_featurize 表里content字段目前已经是向量了
load parquet.`/tmp/tfidf/data` 
as lwys_corpus_with_featurize;
```

 
#### 支持自定义实现算法
除了 Byzer 里已经实现的算法，你也可以用 python 脚本来完成自定义算法。目前通过 PythonAlg 模块支持 SKlearn，Tensorflow，Xgboost，Fasttext 等众多 python 算法框架。 Tensorflow 则支持 Cluster 模式。

#### 部署
BigQuery ML 和 Byzer 都支持直接在 SQL 里使用其预测功能。Byzer 还支持将模型部署成 API 服务。具体做法超级简单:

单机模型运行 StreamingPro.
通过接口或者配置注册算法模型 ```register NaiveBayes./tmp/bayes_modelas bayes_predict;```
访问预测接口

```sql
http://127.0.0.1:9003/model/predict? pipeline= bayes_predict&data=[[1,2,3...]]&dataType=vector
```

Byzer 可以实现 end2end 模式部署，复用所有数据处理流程。

#### 模型多版本管理
训练时将 keepVersion = "true"，每次运行都会保留上一次版本。

#### 多个算法/多组参数并行运行
如果算法自身已经是分布式计算的，那么 Byzer 允许多组参数顺序执行。比如这个：

```sql
train data as ALSInPlace.`/tmp/als` where
-- 第一组参数
`fitParam.0.maxIter`="5"
and `fitParam.0.regParam` = "0.01"
and `fitParam.0.userCol` = "userId"
and `fitParam.0.itemCol` = "movieId"
and `fitParam.0.ratingCol` = "rating"
-- 第二组参数    
and `fitParam.1.maxIter`="1"
and `fitParam.1.regParam` = "0.1"
and `fitParam.1.userCol` = "userId"
and `fitParam.1.itemCol` = "movieId"
and `fitParam.1.ratingCol` = "rating"
-- 计算rmse     
and evaluateTable="test"
and ratingCol="rating"
-- 针对用户做推荐，推荐数量为10  
and `userRec` = "10"
-- 针对内容推荐用户，推荐数量为10
-- and `itemRec` = "10"
and coldStartStrategy="drop"
```

这是一个协同推荐的一个算法，使用者配置了两组参数，因为该算法本身是分布式的，所以两组参数会串行运行。

```sql
-- train sklearn model
train data as PythonAlg.`${modelPath}` 
 
-- specify the location of the training script 
where pythonScriptPath="${sklearnTrainPath}"
 
-- kafka params for log
and `kafkaParam.bootstrap.servers`="${kafkaDomain}"
and `kafkaParam.topic`="test"
and `kafkaParam.group_id`="g_test-2"
and `kafkaParam.userName`="pi-algo"
-- distribute training data, so the python training script can read 
and  enableDataLocal="true"
and  dataLocalFormat="json"
 
-- sklearn params
-- use SVC
and `fitParam.0.moduleName`="sklearn.svm"
and `fitParam.0.className`="SVC"
and `fitParam.0.featureCol`="features"
and `fitParam.0.labelCol`="label"
and `fitParam.0.class_weight`="balanced"
and `fitParam.0.verbose`="true"
 
and `fitParam.1.moduleName`="sklearn.naive_bayes"
and `fitParam.1.className`="GaussianNB"
and `fitParam.1.featureCol`="features"
and `fitParam.1.labelCol`="label"
and `fitParam.1.class_weight`="balanced"
and `fitParam.1.labelSize`="26"
 
-- python env
and `systemParam.pythonPath`="python"
and `systemParam.pythonParam`="-u"
and `systemParam.pythonVer`="2.7";
```

上面这个则是并行运行两个算法 SVC/GaussianNB。因为每个算法自身无法分布式运行，所以 Byzer 允许你并行运行这两个算法。

### 总结
BigQuery ML 只是 Google BigQuery 服务的一部分。所以其实和其对比还有失偏颇。Byzer 把数据平台和算法平台合二为一，在上面你可以做 ETL，流式，也可以做算法，大家都统一用一套 SQL 语法。 Byzer 还提供了大量使用的“数据处理模型”和 SQL 函数，这些无论对于训练还是预测都有非常大的帮助，可以使得数据预处理逻辑在训练和预测时得到复用，基本无需额外开发，实现端到端的部署，减少企业成本。

