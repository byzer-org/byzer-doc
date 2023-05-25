# 扩展/Train|Run|Predict

Train/Run/Predict 都属于 Byzer-lang 里独有的并且可扩展的句式，一般用于机器学习模型的训练和预测，以及特征工程相关的数据处理操作。

想了解更多 [内置算法](/byzer-lang/zh-cn/ml/algs/README.md) 和 [特征工程](/byzer-lang/zh-cn/ml/feature/README.md) 算子的应用，可跳转置对应章节。

### 1. 基础语法

#### Train

`train` 顾名思义，就是进行训练，主要是对算法进行训练时使用。下面是一个比较典型的示例：

```sql

load json.`/tmp/train` as trainData;

train trainData as RandomForest.`/tmp/rf` where
keepVersion="true"
and fitParam.0.featuresCol="content"
and fitParam.0.labelCol="label"
and fitParam.0.maxDepth="4"
and fitParam.0.checkpointInterval="100"
and fitParam.0.numTrees="4"
;
```

- 第一行代码，含义是加载位于 `/tmp/train` 目录下的，数据格式为 JSON 的数据，并且给该表取名为 `trainData`；
- 第二行代码，则表示提供 `trainData` 为数据集，使用算法 RandomForest，将模型保存在 `/tmp/rf` 下，训练的参数为 `fitParam.0.*` 参数组里指定的那些。其中 `fitParam.0` 表示第一组参数，用户可以递增设置 N 组，Byzer-lang 会自动运行多组，最后返回结果列表。例如：

```sql
load json.`/tmp/train` as trainData;

train trainData as RandomForest.`/tmp/rf` where
-- 每次模型不要覆盖，保持版本
keepVersion = "true"
and `fitParam.0.labelCol`= "label"  --y标签
and `fitParam.0.featuresCol`= "features"  -- x特征
and `fitParam.0.maxDepth`= "4"

--设置了两组参数同时运行可对比结果优劣
and `fitParam.1.labelCol`= "label"  --y标签
and `fitParam.1.featuresCol`= "features"  -- x特征
and `fitParam.1.maxDepth`= "10";
```



#### Run

`run` 的语义是对数据进行处理，而不是训练。

下面来看一个例子：

```sql
run testData as TableRepartition.`` where partitionNum="5" as newdata; 
```

格式和 `train` 是一致的，其含义为运行 `testData` 数据集，使用内置插件 TableRepartition 对其重分区处理，
处理的参数是 `partitionNum="5"`，最后处理后的表叫 `newdata`。




#### Predict

`predict` 顾名思义，应该和机器学习相关预测相关。比如上面的 train 示例中，用户将随机森林的模型放在了
`/tmp/rf` 目录下，用户可以通过 `predict` 语句加载该模型，并且对表 `testData` 进行预测。

示例代码如下：

```sql
predict testData as RandomForest.`/tmp/rf`;
```

