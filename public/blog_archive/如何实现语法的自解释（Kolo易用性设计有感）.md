## 如何实现语法的自解释（Byzer易用性设计有感）
突然想明白了一件事， 语法应该是自解释的。什么意思呢，就是用户需要有一个学习语法的语法，而这个语法应该极度简单，他只要花上一分钟，甚至依靠直觉就能知道怎么用，透过这个口，以点窥面，让用户具备自主学习其他语法的能力。

系统如果能从这个层面考虑，那么易用性就会好很多。通常而言，文档少了没安全感，文档多了，寻找到对应的信息又是难事，然后只能各种 Google。

但是如果语法自解释了，会是个什么样子的呢？

比如在 Byzer 里，对于模型，用户只要记住一个关键字 model
一个简单的 load 语法，然后完了就可以了。

第一次是这样：

```sql
 load model.`` as output;
 ```

接着用户用户使用

```sql
load model.`list` as output;
```

得到可用模型的列表：

```
name                        type
---------------------------
PythonAlg                process
RandomForest        algorithm
.....
```

然后我想试试 RandomForest :

```sql
 load model.`params` where alg="RandomForest"  as output;
-- or
 load modelParams.`RandomForest ` as output;
```

接着能给我例子么？

```sql
 load model.`example`  where alg="RandomForest" as output;
-- or
 load modelExample.`RandomForest ` as output;
```
则显示如下内容

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
select vec_dense(features) as features ,label as label from data
as data1;
 
-- use RandomForest
train data1 as RandomForest.`/tmp/model` where
 
-- once set true,every time you run this script, Byzer will generate new directory for you model
keepVersion="true" 
 
-- specicy the test dataset which will be used to feed evaluator to generate some metrics e.g. F1, Accurate
and evaluateTable="data1"
 
-- specify group 0 parameters
and `fitParam.0.labelCol`="features"
and `fitParam.0.featuresCol`="label"
and `fitParam.0.maxDepth`="2"
 
-- specify group 1 parameters
and `fitParam.0.featuresCol`="features"
and `fitParam.0.labelCol`="label"
and `fitParam.1.maxDepth`="10"
;
```
 
自此，用户其实已经自助看完了一篇文档。这么做的好处是：

写代码的同时也是写文档
所有参数/模型都有自省机制。比如 Spark MLlib params 就做的非常好，可以很容易的罗列出可用参数。那么其实模型也是可以做到的。比如这个模型是用来做数据处理的还是做算法的，我们需要在类里面有对应的信息，无论是通过 Annotation 或者是方法。
用户在使用 load 语法查看功能的时候，就已经熟悉了 Byzer 的使用模式了。

