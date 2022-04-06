# 混淆矩阵/ConfusionMatrix

什么是混淆矩阵呢？

混淆矩阵其实就是把所有类别的预测结果与真实结果按类别放置到了同一矩阵中，在这个矩阵中我们可以清楚看到每个类别正确识别的数量和错误识别的数量。在分类算法里用处很多，用户可以直观看到数据的错误分布情况。

<p align="center">
    <img src="/byzer-lang/zh-cn/ml/feature//images/ConfusionMatrix.png" alt="name"  width="500"/>
</p>

### 1. 数据准备

假设我们有动物分类，两列中一列是实际值，另一列是预测值，内容如下：

```sql
set rawData='''
{"label":"cat","predict":"rabbit"}
{"label":"cat","predict":"dog"}
{"label":"cat","predict":"cat"}
{"label":"dog","predict":"dog"}
{"label":"cat","predict":"dog"} 
''';
load jsonStr.`rawData` as data;
```
结果如下：
<p align="center">
    <img src="/byzer-lang/zh-cn/ml/feature//images/ConfusionMatrix2.png" alt="name"  width="600"/>
</p>

### 2. 训练

使用混淆矩阵来查看最后的预测结果分布：

```sql
train data as ConfusionMatrix.`/tmp/model` 
where actualCol="label" 
and predictCol="predict";

load parquet.`/tmp/model/data` as output;
```

**代码含义**：

- 采用 `ConfusionMatrix` 算子对数据集 **data** 进行训练处理，并将该组设置以特征工程模型的形式保存在`/tmp/model` 路径下。
- 参数 `actualCol` 用于指定实际值所在列名。
- 参数 `predictCol` 用于指定预测值所在列名。



结果如下：

<p align="center">
    <img src="/byzer-lang/zh-cn/ml/feature//images/ConfusionMatrix3.png" alt="name"  width="800"/>
</p>

另外我们也可以看到一些统计值：

```sql
load parquet.`/tmp/model/detail` as output;
```

结果如下：
<p align="center">
    <img src="/byzer-lang/zh-cn/ml/feature//images/ConfusionMatrix4.png" alt="name"  width="800"/>
</p>
