## 扩展/Train|Run|Predict

Train/Run/Predict 都属于Kolo-lang里独有的，并且可扩展的结构。

### 基础语法

#### Train
首先是train。 train顾名思义，就是进行训练，主要是对算法进行训练时使用。下面是一个比较典型的示例：

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

如果我们用白话文去读这段话，应该是这么念的：

```
加载位于/tmp/train目录下的，数据格式为json的数据，我们把这些数据叫做trainData, 接着，
我们对trainData进行训练，使用算法RandomForest，将模型保存在/tmp/rf下，训练的参数为 fitParam.0.* 指定的那些。
```

其中fitParam.0 表示第一组参数，用户可以递增设置N组，Kolo-lang会自动运行多组，最后返回结果列表。

#### Run

run的语义是对数据进行处理，而不是训练，他是符合大数据处理的语义的。我们下面来看一个例子：

```sql
run testData as TableRepartition.`` where partitionNum="5" as newdata; 
```

格式和train是一致的，那这句话怎么读呢？

```
运行testData数据集，并且使用TableRepartition进行处理，处理的参数是partitionNum="5"，最后处理后的结果我们取名叫newdata
```
TableRepartition是用于从新分区的一个模块，也就是将数据集重新分成N分，N由partitionNum配置。

### Predict

那么predict呢？ predict语句我们一看，应该就知道是和机器学习相关的，对的，他是为了批量预测用的。比如前面，我们将训练随机森林的结果模型放在了
`/tmp/rf` 目录下，现在我们可以通过predict语句加载他，并且预测新的数据。

```sql
predict testData as RandomForest.`/tmp/rf`;
```

这句话的意思是，对表testData进行预测，预测的算法是RandomForest，对应的模型在 `/tmp/rf` 下。

### 概念

无论是Train/Run/Predict , 他的核心都是对应的算法或者处理工具，实现表进表出（中间可能会有文件输出），弥补传统SQL的不足。
我们把他们统一称为`ET`, 也就是Estimator/Transformer的缩写。

ET都是可扩展的，用户可以完成自己的ET组件。在开发者指南中，有更详细的关于如何开发自己ET的介绍。

### 查看系统可用ET

可使用功能如下命令查看所有可用的 ET：

```
!show et;
```

### 模糊匹配查询ET
需要模糊匹配某个ET的名字，可以使用如下方式：

```sql
!show et;
!lastCommand named ets;
select * from ets where name like "%Random%" as output;
```

同理，你也可以实现根据关键字模糊检索doc字段。

### 查看 ET代码示例和使用文档

通过上面的方式，知道ET具体名字后，你可以查看该ET的使用示例等信息：

```
!show et/RandomForest;
```

### 查看 ET 可选参数
此外，如果你想看到非常详尽的参数信息，可以通过如下命令：

```
!show et/params/RandomForest;
```







