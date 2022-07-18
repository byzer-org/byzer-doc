# 模型自解释性

模型训练后，可以使用 `modelExplain` 语法查看模型参数。下面举例说明。
首先，训练 2 个随机森林模型，并保存至 `/tmp/model` 目录。

```sql
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
load jsonStr.`jsonStr` as mock_data;


select vec_dense(features) as features, label as label from mock_data as mock_data_1;

-- use RandomForest
train mock_data_1 as RandomForest.`/tmp/model` 
where keepVersion="true" 
and evaluateTable="mock_data_validate"
and `fitParam.0.labelCol`="label"
and `fitParam.0.featuresCol`="features"
and `fitParam.0.maxDepth`="2"

and `fitParam.1.featuresCol`="features"
and `fitParam.1.labelCol`="label"
and `fitParam.1.maxDepth`="10" ;
```

完成后，结果显示模型目录分别是 `/tmp/model/_model_8/model/1 ` 和 `/tmp/model/_model_8/model/0` 
<p align="center">
    <img src="/byzer-lang/zh-cn/ml/algs/images/model_path.png" alt="model_path"  width="800"/>
</p>

然后，查看模型参数。
```sql
load modelExplain.`/tmp/model/` where alg="RandomForest" and index="8" as output;
```
这里，结合 `/tmp/model` 和 `index="8"` ，系统读取 `/tmp/model/_model_8` 的模型，并以随机森林算法解释之。上面的语句等价于
```sql
load modelExplain.`/tmp/model/_model_8` where alg="RandomForest" as output;
```