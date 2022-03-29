# 交替最小二乘法/ALS

ALS在协同算法里面很流行。通过它可以很方便的搭建一个推荐系统。

他的数据格式比较简单，需要 userCol， itemCol，ratingCol 三个。

```sql
set jsonStr='''
{"a":1,"i":2,"rate":1},
{"a":1,"i":3,"rate":1},
{"a":2,"i":2,"rate":1},
{"a":2,"i":7,"rate":1},
{"a":1,"i":2,"rate":1},
{"a":1,"i":6,"rate":1},
''';

load jsonStr.`jsonStr` as data;
```

现在我们可以使用ALS进行训练了：

```sql
train data as ALSInPlace.`/tmp/model` where

-- the first group of parameters
`fitParam.0.maxIter`="5"
and `fitParam.0.regParam` = "0.01"
and `fitParam.0.userCol` = "a"
and `fitParam.0.itemCol` = "i"
and `fitParam.0.ratingCol` = "rate"

-- the sencond group of parameters    
and `fitParam.1.maxIter`="1"
and `fitParam.1.regParam` = "0.1"
and `fitParam.1.userCol` = "a"
and `fitParam.1.itemCol` = "i"
and `fitParam.1.ratingCol` = "rate"

-- compute rmse     
and evaluateTable="data"
and ratingCol="rate"

-- size of recommending items for user  
and `userRec` = "10"

-- size of recommending users for item
-- and `itemRec` = "10"
and coldStartStrategy="drop";
```

在这里，我们配置了两组参数，并且使用 rmse 来评估效果，最后的结果是给每个用户 10 条内容。如果需要给每个内容推荐 10 个用户则设置 itemRec 参数即可。

最后的结果如下：

<p align="center">
    <img src="/byzer-lang/zh-cn/ml/algs/images/als_result1.png" alt="name"  width="800"/>
</p>
可以看看最后的预测结果：

``` sql
load parquet.`/tmp/model/data/userRec` as userRec;
select * from userRec as result;
```


<p align="center">
    <img src="/byzer-lang/zh-cn/ml/algs/images/als_result2.png" alt="name"  width="800"/>
</p>

### 批量预测

该算法不支持批量预测以及 API 预测。