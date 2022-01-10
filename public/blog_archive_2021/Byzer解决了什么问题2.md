# Byzer 解决了什么问题（二）

先看看做算法有哪些痛点（我们假设大部分算法的代码都是基于 Python 的）：

1. 项目难以重现，可阅读性和环境要求导致能把另外一个同事写的 python 项目运行起来不得不靠运气
2. 和大数据平台衔接并不容易，需要让研发重新做工程实现，导致落地周期变长。
3. 训练时数据预处理/特征化无法在预测时复用
4. 集成到流式，批处理和提供 API 服务都不是一件容易的事情
5. 代码/算法复用级别有限，依赖于算法自身的经验以及自身的工具箱，团队难以共享。
6. 其他团队很难接入算法的工作

Byzer 如何解决这些问题呢？

### 统一交互语言
Byzer 提供了一套 SQL 的超集的 DSL 语法 Byzer，数据处理，模型训练，模型预测部署等都是以 Byzer 语言交互，该语言简单易懂，无论算法，分析师，甚至运营都能看懂，极大的减少了团队的沟通成本，同时也使得更多的人可以做算法方面的工作。

### 数据预处理 / 算法模块化
所有较为复杂的数据预处理和算法都是模块化的，通过函数以及纯 SQL 来进行衔接。比如：

```sql
-- load data
load parquet.`${rawDataPath}` as orginal_text_corpus;
 
-- select only columns we care
select feature,label from orginal_text_corpus as orginal_text_corpus;
 
-- feature enginere moduel
train zhuml_orginal_text_corpus  as TfIdfInPlace.`${tfidfFeaturePath}` 
where inputCol="content" 
and `dic.paths`="/data/dict_word.txt" 
and stopWordPath="/data/stop_words"
and nGrams="2";
 
-- load data
load parquet.`${tfidfFeaturePath}/data` as tfidfdata;
 
--  algorithm module
train zhuml_corpus_featurize_training as PythonAlg.`${modelPath}` 
where pythonScriptPath="${sklearnTrainPath}"
-- kafka params for log
and `kafkaParam.bootstrap.servers`="${kafkaDomain}"
and `kafkaParam.topic`="test"
and `kafkaParam.group_id`="g_test-2"
and `kafkaParam.userName`="pi-algo"
-- distribute data
and  enableDataLocal="true"
and  dataLocalFormat="json"
-- sklearn params
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
and `fitParam.1.labelSize`="2"
 
-- python env
and `systemParam.pythonPath`="python"
and `systemParam.pythonParam`="-u"
and `systemParam.pythonVer`="2.7";
```

这段小脚本脚本完成了数据加载，特征工程，最后的训练。所有以 train 开头的，都是模块，以 select 开头的都是标准 sql，
以 load 开头的则是各种数据源的加载。

在 Byzer 中，任何一个模块都有两个产出：模型和函数。训练时该模块会产生一个对应的模型，预测时该模型会提供一个函数，从而实现

1. 对训练阶段的数据处理逻辑，在预测时能进行复用。
2. 算法训练的模型可以直接部署成一个预测函数。

### 标准遵循
所有数据处理模块，算法模块，都有标准的暴露参数的方式，也就是前面例子类似下面的句子：

```sql
and `fitParam.0.labelCol`="label"
and `fitParam.0.class_weight`="balanced"
and `fitParam.0.verbose`="true"
```

比如该算法暴露了 class_weight，labelCol，verbose 等参数。所有人开发的算法模块和数据处理模块都可以很好的进行复用。

### 分布式和单机多种部署形态
Byzer 是基于 Spark 改造而成，这就直接继承了 Spark 的多个优点：

1. 你可以在 Byzer 里获取基本上大部分存储的支持，比如 ES，MySQL，Parquet，ORC，JSON，CSV等等
2. 你可以部署在多种环境里，比如 Yarn，Mesos，Local 等模式

### 数据处理模块/算法模型易于部署
同行启动一个 local 模式的 Byzer Server，然后注册我们训练的时候使用到的数据处理模块和算法模块，每个模块都会产生一个函数，接着就能通过 http 接口传递一个函数嵌套的方式完成一个 pipeline 的使用了。对于函数我们确保其响应速度，一般都是在毫秒级。
注册就是一个简单的 register 语句：

```sql
-- transform model into udf
register PythonAlg.`${modelPath}` as topic_spam_predict options 
pythonScriptPath="${sklearnPredictPath}"
;
```

支持所有提供了 Python 语言接口的算法框架的集成
只要实现 Byzer 的标准规范，你就能够轻而易举的将各种框架集成到 Byzer 中。目前已经支持 SKlearn，同时有 Keras 图片处理等相关例子。算法可以专注于算法模块的研发，研发可以专注于数据处理模块的开发，所有的人都可以通过 Byzer 复用这些模块，完成算法业务的开发。
