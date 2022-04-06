# 归一化/NormalizeInPlace

特征归一化本质上是为了统一量纲，让一个向量里的元素变得可以比较。

它应用于任何依赖于距离的算法，比如 KMeans，Nearest Neighbors Methods， RBF Kernels 等等。

### 1. 数据准备

```sql
-- 创建数据集，这里创建一份js string 类型的
set jsonStr='''
{"a":1,    "b":100, "label":0.0},
{"a":100,  "b":100, "label":1.0}
{"a":1000, "b":100, "label":0.0}
{"a":10,   "b":100, "label":0.0}
{"a":1,    "b":100, "label":1.0}
''';
load jsonStr.`jsonStr` as data;
```

结果如下：
<p align="center">
    <img src="/byzer-lang/zh-cn/ml/feature//images/ScalerInPlace1.png" alt="name"  width="800"/>
</p>


### 2. 训练

对 **a,b** 两列数据进行归一化操作。

```sql
train data as NormalizeInPlace.`/tmp/model`
where inputCols="a,b"
and scaleMethod="standard"
and removeOutlierValue="false"
;

load parquet.`/tmp/model/data` 
as output;
```

**代码含义**：

- 采用 `NormalizeInPlace` 算子对数据集 **data** 进行训练处理，并将该组设置以特征工程模型的形式保存在`/tmp/model` 路径下。
- 参数 `inputCols` 用于设置参与处理的列名。
- 参数 `scaleMethod` 用于设置归一化的处理方式，可选项还有：`p-norm` 。
- 参数 `removeOutlierValue` 控制是否自动填充异常值。若设置为true，则会自动用中位数填充异常值。

> 如果 `inputCols` 只有一列，那么该列可以为 double 数组 
>
> 可以使用命令：!show "et/params/NormalizeInPlace"; 查看该算子包含的所有参数的使用方式


结果如下：
<p align="center">
    <img src="/byzer-lang/zh-cn/ml/feature//images/normalized.png" alt="name"  width="800"/>
</p>



### 3. API 预测

```sql
register NormalizeInPlace.`/tmp/model` as convert;
```

通过上面的命令，就可以将该归一化模型训练结果通过 `register` 语句注册成一个函数，这里命名为：**convert**，注册成功的函数会把训练阶段学习到的东西应用起来。

现在，任意给定两个数字，都可以使用 `convert` 函数将内容归一化处理。

```sql
select convert(array(cast(7.0 as double), cast(8.0 as double))) as features as output;
```

输出结果为：

```
features
[ -0.4932558994483363, 0 ]
```

