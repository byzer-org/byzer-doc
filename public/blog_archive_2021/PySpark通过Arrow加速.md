## PySpark 通过 Arrow 加速

### 前言
PySpark 是 Spark 实现 Unify BigData && Machine Learning 目标的基石之一。通过PySpark，我们可以用 Python 在一个脚本里完成数据加载，处理，训练，预测等完整 Pipeline，加上 DB 良好的 notebook 的支持，数据科学家们会觉得非常开心。当然缺点也是有的，就是带来了比较大的性能损耗。

### 性能损耗点分析
如果使用 PySpark，大概处理流程是这样的(注意，这些都是对用户透明的)

1. Python 通过 socket 调用 Spark API（py4j 完成），一些计算逻辑，python 会在调用时将其序列化，一并发送给 Spark。
2. Spark 触发计算，比如加载数据，然后把数据转成内部存储格式 InternalRow，接着启动 Python Deamon，Python Deamon 再启动多个 Worker,
3. 数据通过 socket 协议发送给 Python Worker（不跨网络），期间需要将 InternalRow 转化为Java 对象，然后再用 Java Pickle 进行序列化(一次)，这个时候才能通过网络发送给 Worker
4. Worker 接收后，一条一条反序列化(python pickle 两次)，然后转化为 Python 对象进行处理。拿到前面序列化好的函数反序列化，接着用这个函数对这些数据处理，处理完成后，再用 pickle 进行序列化（三次），发送给 Java Executor.
5. Java Executor 获取数据后，需要反序列化（四次），然后转化为 InternalRow 继续进行处理。


所以可以看到，前后需要四次编码/解码动作。序列化反序列化耗时应该占用额外耗时的 70% 左右。我们说，有的时候把序列化框架设置为 Kyro 之后，速度明显快了很多，可见序列化的额外耗时是非常明显的。

前面是一个点，第二个点是，数据是按行进行处理的，一条一条，显然性能不好。

第三个点是，Socket 协议通讯其实还是很快的，而且不跨网络，只要能克服前面两个问题，那么性能就会得到很大的提升。 另外可以跟大家说的是，Python 如果使用一些 C 库的扩展，比如 Numpy 本身也是非常快的。

### 如何开启 Arrow 进行加速，以及背后原理
开启方式很简单，启动时加上一个配置即可：

```python

if __name__ == '__main__':
    conf = SparkConf()
    conf.set("spark.sql.execution.arrow.enabled", "true")
```
你也可以在 submit 命令行里添加。

### 那么 Arrow 是如何加快速度的呢？主要是有两点：

1. 序列化友好
2. 向量化


序列化友好指的是，Arrow 提供了一个内存格式，该格式本身是跨应用的，无论你放到哪，都是这个格式，中间如果需要网络传输这个格式，那么也是序列化友好的，只要做下格式调整（不是序列化）就可以将数据发送到另外一个应用里。这样就大大的降低了序列化开销。

向量化指的是，首先 Arrow 是将数据按 block 进行传输的，其次是可以对立面的数据按列进行处理的。这样就极大的加快了处理速度。

### 实测效果
为了方便测试，我定义了一个基类：

```python
from pyspark import SQLContext
from pyspark import SparkConf
from pyspark import SparkContext
from pyspark.sql import SparkSession
import os
 
os.environ["PYSPARK_PYTHON"] = "/Users/allwefantasy/deepavlovpy3/bin/python3"
 
class _SparkBase(object):
    @classmethod
    def start(cls, conf=SparkConf()):
        cls.sc = SparkContext(master='local[*]', appName=cls.__name__, conf=conf)
        cls.sql = SQLContext(cls.sc)
        cls.session = SparkSession.builder.getOrCreate()
        cls.dataDir = "/Users/allwefantasy/CSDNWorkSpace/spark-deep-learning_latest"
 
    @classmethod
    def shutdown(cls):
        cls.session.stop()
        cls.session = None
        cls.sc.stop()
        cls.sc = None
```
 
接着提供了一个性能测试辅助类：

```python
import time
from functools import wraps
import logging
 
logger = logging.getLogger(__name__)
 
PROF_DATA = {}
 
 
def profile(fn):
    @wraps(fn)
    def with_profiling(*args, **kwargs):
        start_time = time.time()
 
        ret = fn(*args, **kwargs)
 
        elapsed_time = time.time() - start_time
 
        if fn.__name__ not in PROF_DATA:
            PROF_DATA[fn.__name__] = [0, []]
        PROF_DATA[fn.__name__][0] += 1
        PROF_DATA[fn.__name__][1].append(elapsed_time)
 
        return ret
 
    return with_profiling
 
 
def print_prof_data(clear):
    for fname, data in PROF_DATA.items():
        max_time = max(data[1])
        avg_time = sum(data[1]) / len(data[1])
        logger.warn("Function %s called %d times. " % (fname, data[0]))
        logger.warn('Execution time max: %.3f, average: %.3f' % (max_time, avg_time))
    if clear:
        clear_prof_data()
 
 
def clear_prof_data():
    global PROF_DATA
    PROF_DATA = {}
```
很简单，就是 wrap 一下实际的函数，然后进行时间计算。现在，我们写一个 PySpark 的类：

```python
import logging
from random import Random
 
import pyspark.sql.functions as F
from pyspark import SparkConf
from pyspark.sql.types import *
 
from example.allwefantasy.base.spark_base import _SparkBase
import example.allwefantasy.time_profile as TimeProfile
import pandas as pd
 
logger = logging.getLogger(__name__)
class PySparkOptimize(_SparkBase):
    def trick1(self):   
        pass 
 
if __name__ == '__main__':
    conf = SparkConf()
    conf.set("spark.sql.execution.arrow.enabled", "true")
    PySparkOptimize.start(conf=conf)
    PySparkOptimize().trick1()
    PySparkOptimize.shutdown()
```
这样骨架就搭建好了。

我们写第一个方法 trick1 做一个简单的计数：

```python
    def trick1(self):
        df = self.session.range(0, 1000000).select("id", F.rand(seed=10).alias("uniform"),
                                                   F.randn(seed=27).alias("normal"))
        # 更少的内存和更快的速度
        TimeProfile.profile(lambda: df.toPandas())()
        TimeProfile.print_prof_data(clear=True)
```

并且将前面的 arrow 设置为 false，结果如下：

```
Function <lambda> called 1 times. 
Execution time max: 6.716, average: 6.716
```
然后同样的代码，我们把  arrow 设置为 true，是不是会好一些呢?

```
Function <lambda> called 1 times. 
Execution time max: 2.067, average: 2.067
```
当然我这个测试并不严谨，但是对于这种非常简单的示例，提升还是有效三倍的，不是么？而这，只是改个配置就可以达成了。

分组聚合使用 Pandas 处理
另外值得一提的是，PySpark 是不支持自定义聚合函数的，现在如果是数据处理，可以把 group by 的小集合发给 pandas 处理，pandas 再返回，比如

```python
def trick7(self):
        df = self.session.createDataFrame(
            [(1, 1.0), (1, 2.0), (2, 3.0), (2, 5.0), (2, 10.0)], ("id", "v"))
 
        @F.pandas_udf("id long", F.PandasUDFType.GROUPED_MAP)  
        def normalize(pdf):
            v = pdf.v
            return pdf.assign(v=(v - v.mean()) / v.std())[["id"]]
 
        df.groupby("id").apply(normalize).show() 
```
这里是 id 进行 group by，这样就得到一张 id 列都是 1 的小表，接着呢把这个小表转化为 pandas dataframe 处理，处理完成后，还是返回一张小表，表结构则在注解里定义，比如只返回 id 字段，id 字段是 long 类型。

