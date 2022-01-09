# 部署流程

?> 本章涉及 Byzer API 相关知识，详情可以翻看 [Byzer Engine Rest API](/byzer-lang/zh-cn/developer/api/README.md)

经过优化，Byzer 的 `Local` 模式可以实现毫秒级的预测效果。

### 部署步骤

**1. 启动 Byzer** 

> 关于 Byzer 的启动和部署，详情可以查看 [Byzer-lang 安装与配置](/byzer-lang/zh-cn/installation/binary-installation.md)

使用 `Local` 模式，通常你可以认为这是一个标准的 Java 应用，启动脚本参考：

```
./bin/spark-submit   --class streaming.core.StreamingApp \
--master local[2] \
--name predict_service \
streamingpro-mlsql-x.x.xjar    \
-streaming.name predict_service    \
-streaming.platform spark   \
-streaming.rest true   \
-streaming.driver.port 9003   \
-streaming.spark.service true \
-streaming.thrift false \
-streaming.enableHiveSupport true \
-streaming.deploy.rest.api true 
```

其中最后一行 `-streaming.deploy.rest.api true` 开启了优化，可以让 Byzer 示例跑的更快。

**2. 动态注册模型**

访问 `http://127.0.0.1:9003/run/script` 接口在训练阶段生成的模型：

```sql
register TfIdfInPlace.`/tmp/tfidf_model` as tfidf_predict;
register RandomForest.`/tmp/rf_model` as bayes_predict;
```

**3. 预测请求**

访问：`http://127.0.0.1:9003/model/predict`进行：

请求参数为：

| Property Name	 | Default  |Meaning |
|:-----------|:------------|:------------|
|dataType|vector|data字段的数据类型，目前只支持 `vector`/`string`/`row` |
|data|[]|你可以传递一个或者多个 `vector`/`string`/`json` ,必须符合 json 规范|
|sql|None|用 sql 的方式调用模型，其中如果是 `vector`/`string` ,则模型的参数 feature 是固定的字符串，如果是 row 则根据 key 决定|
|pipeline|None|用 pipeline 的方式调用模型，参数为用逗号分隔的模型名，通常只能支持 `vector`/`string` 模式|

例子：

```sql
dataType=row
data=[{"feature":[1,2,3...]}]
sql=select bayes_predict(vec_dense(feature)) as p
```

### 完整示例

完整示例增加了数据准备、模型训练的相关内容，可以更清晰的查看全部流程。

**1. 数据准备**

```sql
--NaiveBayes
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

**2. 模型训练**

```
-- use RandomForest
train data1 as RandomForest.`/tmp/model` where

-- once set true,every time you run this script, MLSQL will generate new directory for you model
keepVersion="true" 

-- specicy the test dataset which will be used to feed evaluator to generate some metrics e.g. F1, Accurate
and evaluateTable="data1"

-- specify group 0 parameters
and `fitParam.0.labelCol`="features"
and `fitParam.0.featuresCol`="label"
and `fitParam.0.maxDepth`="2"

-- specify group 1 parameters
and `fitParam.1.featuresCol`="features"
and `fitParam.1.labelCol`="label"
and `fitParam.1.maxDepth`="10"
;

```

**3. 启动 Byzer** 

同上面启动流程
   
**4. 注册模型**

```
register RandomForest.`/tmp/model` as rf_predict;
```

**5. 外部调用**

接着就可以外部调用 API 使用了,需要传递两个参数：

```
dataType=row
data=[{"feature":[1,2,3...]}]
sql=select rf_predict(vec_dense(feature)) as p
owner=admin
sessionPerUser=true
```

> 其中，sessionPerUser=true是控制按照租户区分session。

最后的预测结果为：

```
{
    "p": {
        "type": 1,
        "values": [
            1,
            0
        ]
    }
}

```

不仅仅是算法，大部分模块都可以通过这种方式进行注册和调用。
Byzer 实现了端到端的部署，也就是说，你也可以将预处理逻辑、预测模型同时部署。
通过 `select` 语法，你还可以完成一些更为复杂的预测逻辑。


