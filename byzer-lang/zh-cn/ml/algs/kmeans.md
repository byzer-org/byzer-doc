# K 均值聚类算法/KMeans

KMeans，k均值聚类算法（k-means clustering algorithm）是一种迭代求解的聚类分析算法，其步骤是，预将数据分为K组，则随机选取K个对象作为初始的聚类中心，然后计算每个对象与各个种子聚类中心之间的距离，把每个对象分配给距离它最近的聚类中心。

首先我们新增一些数据。

``` sql
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
select vec_dense(features) as features from data
as data1;
```

结果如下：

<p align="center">
    <img src="/byzer-lang/zh-cn/ml/algs/images/kmeans_result1.png" alt="name"  width="800"/>
</p>

聚类算法属于无监督算法，所以没有 Label 的概念。接着，我们可以训练了：

``` sql
train data1 as KMeans.`/tmp/alg/kmeans`
where k="2"
and seed="1";
```
### 批量预测
无

### API 预测
训练完成后，可以注册模型为函数，进行预测：

``` sql
register KMeans.`/tmp/alg/kmeans` as kcluster;
select kcluster(features) as catagory from data1 as output;
```

结果如下：

<p align="center">
    <img src="/byzer-lang/zh-cn/ml/algs/images/kmeans_result2.png" alt="name"  width="800"/>
</p>


