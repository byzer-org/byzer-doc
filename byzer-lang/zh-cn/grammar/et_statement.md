# 扩展/Train|Run|Predict

Train/Run/Predict 都属于 Byzer-lang 里独有的，并且可扩展的句式。

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




第一行代码，含义是加载位于 `/tmp/train` 目录下的，数据格式为 JSON 的数据，并且给该表取名为 `trainData`, 
第二行代码，则表示提供 `trainData` 为数据集，使用算法 RandomForest，将模型保存在 `/tmp/rf` 下，训练的参数为 `fitParam.0.*` 指定的那些。


其中 `fitParam.0` 表示第一组参数，用户可以递增设置 N 组，Byzer-lang 会自动运行多组，最后返回结果列表。

#### Run

`run` 的语义是对数据进行处理，而不是训练。

下面来看一个例子：

```sql
run testData as TableRepartition.`` where partitionNum="5" as newdata; 
```

格式和 `train` 是一致的，其含义为运行 `testData` 数据集，使用 ET TableRepartition 对其重分区处理，
处理的参数是 `partitionNum="5"`，最后处理后的表叫 `newdata`。


#### Predict

`predict` 顾名思义，应该和机器学习相关预测相关。比如上面的 train 示例中，用户将随机森林的模型放在了
`/tmp/rf` 目录下，用户可以通过 `predict` 语句加载该模型，并且对表 `testData` 进行预测。

示例代码如下：

```sql
predict testData as RandomForest.`/tmp/rf`;
```


### ET 概念

无论是 Train/Run/Predict, 他的核心都是对应的算法或者处理工具，实现表进表出（中间可能会有文件输出），弥补传统 SQL 的不足。
在 Byzer-lang 中把他们统一称为 `ET`, 也就是 Estimator/Transformer 的缩写。

`ET` 都是可扩展的，用户可以完成自己的 `ET` 组件。在开发者指南中，有更详细的关于如何开发自己 `ET` 的介绍。

### 查看系统可用 ET

可使用功能如下命令查看所有可用的 `ET`：

```
!show et;
```

### 模糊匹配查询 ET

需要模糊匹配某个 `ET` 的名字，可以使用如下方式：

```sql
!show et;
!lastCommand named ets;
select * from ets where name like "%Random%" as output;
```

同理，你也可以实现根据关键字模糊检索 `doc` 字段。

### 查看 ET 代码示例和使用文档

通过上面的方式，知道 `ET` 具体名字后，你可以查看该 `ET` 的使用示例等信息：

```
!show et/RandomForest;
```

### 查看 ET 可选参数

此外，如果你想看到非常详尽的参数信息，可以通过如下命令：

```
!show et/params/RandomForest;
```







