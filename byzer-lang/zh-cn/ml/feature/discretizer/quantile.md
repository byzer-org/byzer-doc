# Quantile

Quantile 的使用只需要指指定对应 bucket 数目即可。

### 数据准备

假设我们有如下数据：

```sql
-- create test data
SET jsonStr='''
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
LOAD jsonStr.`jsonStr` AS data;
SELECT features[0] AS a ,features[1] AS b FROM data
as data1;
```

最终得到了a,b两个字段，对它们分别进行切分，转化为离散值：

```sql
TRAIN data1 AS Discretizer.`/tmp/model`
WHERE method="quantile"
and `fitParam.0.inputCol`="a"
and `fitParam.0.outputCol`="a_v"
and `fitParam.0.numBuckets`="3"
and `fitParam.1.inputCol`="b"
and `fitParam.1.outputCol`="b_v"
and `fitParam.1.numBuckets`="3";
```

这里，我们使用 `fitParam.0` 表示第一组(a)切分规则，`fitParam.1` 表示第二组(b)切分规则。

> 需要注意的是，spark 2.4.x 要求outputCol必须设置。

参数描述：

|parameter|default|comments|
|:----|:----|:----|
|method|bucketizer|support: bucketizer, quantile|
|fitParam.${index}.inputCols|None|double类型字段|
|fitParam.${index}.splitArray|None|bucket array，-inf ~ inf ，size should > 3，[x, y)|

### API 预测

> API 预测的相关原理及示例，详见 [部署算法 API 服务](/byzer-lang/zh-cn/ml/api_service/README.md)
> 该 ET 目前比较特殊查看切分结果需要使用 register 语法注册函数。

```sql
REGISTER Discretizer.`/tmp/model` as convert;
```

通过上面的命令，Discretizer 就会把训练阶段学习到的东西应用起来，现在，可以使用`convert`函数了。

```sql
SELECT convert(array(7,8)) AS features AS output;
```

输出结果为：

```
features
[1,1]
```



 