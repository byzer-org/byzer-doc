# 特征平滑

ScalerInPlace 支持 min-max, log2, logn 方法对数据进行特征平滑。
不同于 NormalizeInPlace，ScalerInPlace 针对的是列。

### 数据准备

```sql
-- create test data
SET jsonStr='''
{"a":1,    "b":100, "label":0.0},
{"a":100,  "b":100, "label":1.0}
{"a":1000, "b":100, "label":0.0}
{"a":10,   "b":100, "label":0.0}
{"a":1,    "b":100, "label":1.0}
''';
LOAD jsonStr.`jsonStr` as data;
```

### 平滑

接着我们对第一列数据a,b两列数据都进行平滑。

```sql
TRAIN data AS ScalerInPlace.`/tmp/scaler`
WHERE inputCols="a,b"
and scaleMethod="min-max"
and removeOutlierValue="false"
;

LOAD parquet.`/tmp/scaler/data` 
as featurize_table;
```

结果如下：

```
a                    b   label
0	                 0.5	0
0.0990990990990991	 0.5	1
1	                 0.5	0
0.009009009009009009 0.5	0
0	                 0.5	1
```

`removeOutlierValue` 设置为true，会自动用中位数填充异常值。


### API 预测

> API 预测的相关原理及示例，详见 [部署算法 API 服务](/byzer-lang/zh-cn/ml/api_service/README.md)

```sql
REGISTER ScalerInPlace.`/tmp/scaler` AS scale_convert;
```

通过上面的命令，ScalerInPlace 就会把训练阶段学习到的东西应用起来。
现在，任意给定两个数字，都可以使用 `scale_convert` 函数将内容转化为向量。

```sql
SELECT scale_convert(array(cast(7.0 as double), cast(8.0 as double))) AS features AS outputt;
```

输出结果为：

```
features
[0.006006006006006006,0.5]
```

