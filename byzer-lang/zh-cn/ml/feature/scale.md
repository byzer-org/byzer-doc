# 特征平滑/ScalerInPlace

ScalerInPlace 支持 min-max， log2，logn 方法对数据进行特征平滑。
不同于 NormalizeInPlace，ScalerInPlace 针对的是列。

### 1. 数据准备

```sql
-- create test data
set jsonStr='''
{"a":1,    "b":100, "label":0.0},
{"a":100,  "b":100, "label":1.0}
{"a":1000, "b":100, "label":0.0}
{"a":10,   "b":100, "label":0.0}
{"a":1,    "b":100, "label":1.0}
''';
load jsonStr.`jsonStr` as data;
```

### 2. 平滑

接着我们对第一列数据a,b两列数据都进行平滑。

```sql
train data as ScalerInPlace.`/tmp/scaler`
where inputCols="a,b"
and scaleMethod="min-max"
and removeOutlierValue="false"
;

load parquet.`/tmp/scaler/data` 
as featurize_table;
```

结果如下：

```
a                        b     label
0	                      0.5	     0
0.0990990990990991	    0.5	     1
1	                      0.5	     0
0.009009009009009009    0.5	     0
0	                      0.5	     1
```

如果将上述代码中的`removeOutlierValue` 设置为true，会自动用中位数填充异常值。


### 3. API 预测

> API 预测的相关原理及示例，详见 [部署算法 API 服务](/byzer-lang/zh-cn/ml/api_service/README.md)

```sql
register ScalerInPlace.`/tmp/scaler` as scale_convert;
```

通过上面的命令，ScalerInPlace 就会把训练阶段学习到的东西应用起来。
现在，任意给定两个数字，都可以使用 `scale_convert` 函数将内容转化为向量。

```sql
select scale_convert(array(cast(7.0 as double), cast(8.0 as double))) as features as output;
```

输出结果为：

```
features
[0.006006006006006006,0.5]
```

