# 数据集切分/RateSampler

在做算法时，我们需要经常对数据切分成 **训练集** 和 **测试集**。
`RateSampler` 算子支持对数据集进行按比例切分。

### 1. 数据准备

```sql
-- 创建数据集
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

结果如下：
<p align="center">
    <img src="/byzer-lang/zh-cn/ml/feature//images/RateSampler1.png" alt="name"  width="700"/>
</p>



### 2. 切分数据集

现在我们使用 RateSampler 进行切分：

```sql
train data as RateSampler.`/tmp/model` 
where labelCol="label"
and sampleRate="0.7,0.3" as marked_dataset;

select * from marked_dataset as output;
```

**代码含义**：

- 采用 `RateSampler` 算子对数据集 **data** 进行训练处理，并将该组设置以特征工程模型的形式保存在`/tmp/model` 路径下。
- 参数 `labelCol` 用于指定切分的字段。
- 参数 `sampleRate` 用于指定切分的比例。

> 可以使用命令：!show "et/params/RateSampler"; 查看该算子包含的所有参数的使用方式

结果如下：
<p align="center">
    <img src="/byzer-lang/zh-cn/ml/feature//images/RateSampler2.png" alt="name"  width="700"/>
</p>


数据集多出了一个字段 `__split__`, 0 表示前一个集合（训练集）， 1 表示后一个集合（测试集）。

接着，可以这样切分出训练集和测试集：

```sql
-- 筛选出训练集
select * from marked_dataset where __split__=0
as trainingTable;

-- 筛选出测试集
select * from marked_dataset where __split__=1
as validateTable;
```

> 默认 `RateSampler` 采用估算算法。
> 如果数据集较小，可以通过设置参数 `isSplitWithSubLabel="true"` 获得非常精确的划分。

### 3. API 预测


该模块暂不提供 API 预测。

