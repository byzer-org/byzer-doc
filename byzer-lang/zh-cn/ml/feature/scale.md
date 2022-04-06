# 特征平滑/ScalerInPlace

特征平滑算子 `ScalerInPlace` 可以将输入特征中包含异常的数据平滑到一定区间，支持阈值平滑和指数平滑等方式。

`ScalerInPlace` 支持 `min-max`， `log2`，`logn` 等方法对数据进行特征平滑。下面将介绍该算子的应用方式。

### 1. 数据准备

这里我们创建一些用于测试的数据

```sql
-- 创建数据集
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


### 2. 对数据进行特征平滑处理

接着我们对 **a,b** 两列数据都进行平滑:

```sql
-- 用 ScalerInPlace 处理数据
train data1 as ScalerInPlace.`/tmp/scaler`
where inputCols="a,b"
and scaleMethod="min-max"
and removeOutlierValue="false"
;

-- 将处理结果 load 出来查看
load parquet.`/tmp/scaler/data` 
as featurize_table;
```

**代码含义**：

- 采用 `ScalerInPlace` 算子对数据集 **data** 进行训练处理，并将该组设置以特征工程模型的形式保存在`/tmp/scaler` 路径下。
- 参数 `inputCols` 用于设置参与处理的列名。
- 参数 `scaleMethod` 用于设置特征平滑的处理方式，可选项还有：`log2`，`logn` 。
- 参数 `removeOutlierValue` 控制是否自动填充异常值。若设置为true，则会自动用中位数填充异常值。

> 可以使用命令：!show "et/params/ScalerInPlace"; 查看该算子包含的所有参数的使用方式

结果如下：

<p align="center">
    <img src="/byzer-lang/zh-cn/ml/feature//images/ScalerInPlace2.png" alt="name"  width="800"/>
</p>




### 3. API 预测

```sql
register ScalerInPlace.`/tmp/scaler` as scale_convert;
```

通过上面的命令，就可以将该特征平滑模型训练结果通过 `register` 语句注册成一个函数，这里命名为：**scale_convert**，注册成功的函数会把训练阶段学习到的东西应用起来。

现在，任意给定两个数字，都可以使用 `scale_convert` 函数将其平滑：

```sql
select scale_convert(array(cast(7.0 as double), cast(8.0 as double))) as features as output;
```

输出结果为：

```
features
[0.006006006006006006,0.5]
```

