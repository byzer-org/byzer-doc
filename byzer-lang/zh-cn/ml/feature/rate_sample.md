# 数据集切分/RateSample

在做算法时，我们需要经常对数据切分成 训练集 和 测试集。
但是如果有些分类数据特别少，可能出现切分不均的情况。
RateSample 支持对每个分类的数据按比例切分。

### 数据准备

```sql
-- create test data
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
```

### 切分

现在我们使用 RateSample 进行切分：

```sql
train data as RateSampler.`` 
where labelCol="label"
and sampleRate="0.7,0.3" as marked_dataset;

select * from marked_dataset as output;
```

其中 `labelCol` 指定切分的字段，`sampleRate` 指定切分比例。

结果如下：

```
features            label   __split__
[5.1,3.5,1.4,0.2]	1	        1
[5.1,3.5,1.4,0.2]	1	        1
[4.7,3.2,1.3,0.2]	1	        0
[5.1,3.5,1.4,0.2]	0	        0
[5.1,3.5,1.4,0.2]	0	        0
[4.4,2.9,1.4,0.2]	0	        0
[5.1,3.5,1.4,0.2]	0	        0
[5.1,3.5,1.4,0.2]	0	        0
```

数据集多出了一个字段 `__split__`, 0 表示前一个集合（训练集）， 1 表示后一个集合（测试集）。

可以这么使用

```sql
select * from marked_dataset where __split__=0
as trainingTable;

select * from marked_dataset where __split__=1
as validateTable;
```

默认 RateSampler 采用估算算法。
如果数据集较小，可以通过设置 `isSplitWithSubLabel="true"` 获得非常精确的划分。

### API 预测

> API 预测的相关原理及示例，详见 [部署算法 API 服务](/byzer-lang/zh-cn/ml/api_service/README.md)


该模块不提供 API 预测。

