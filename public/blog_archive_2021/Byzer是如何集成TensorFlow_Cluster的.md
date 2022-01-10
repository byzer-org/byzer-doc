# Byzer 是如何集成 TensorFlow Cluster 的

### 前言
我们知道 Byzer 支持 SKLearn，TF 等流行的算法框架，不过虽然支持了多个实例同时运行，但其实每个模型都需要跑全部数据。有的时候数据太大，确实是个问题，所以这个时候还是需要引入 Cluster 的。Byzer 基于 Spark，所以问题就变成了如何在 Spark 里集成TF Cluster 了。TFoS 已经实现了类似的功能，但遗憾的是，TFoS 完全是用 Python 编写的，并且每次都需要启动一个新的 Spark 实例来运行，overhead 是比较高的。

### Byzer 集成 TF Cluster
Byzer 集成 TF Cluster 的主要优势有：

1. 一个 Spark 实例可以运行多个 TF Cluster，互不影响。
2. 可以 local 模式运行 TF Cluster
3. 数据交互本地化(也可以消费 Kafka)，假设你配置了 10 个 worker，数据会被切分成十份，然后同步到对应 worker 的本地目录。
4. 易用，你只要写一个 python 脚本，所有调度相关工作全部由 Byzer 来完成。

感兴趣的可以参看这个[ PR ](https://github.com/byzer-org/byzer-lang/pull/359)，看看具体实现源码。

### 一个示例

```sql
load libsvm.`/tmp/william/sample_libsvm_data.txt` as data;
 
train data as DTFAlg.`/tmp/jack`
where
pythonScriptPath="/tmp/tensorflow-distribute.py"
and `kafkaParam.bootstrap.servers`="127.0.0.1:9092"
and `kafkaParam.topic`="test"
and `kafkaParam.group_id`="g_test-1"
and  keepVersion="true"
and  enableDataLocal="true"
and  dataLocalFormat="json"
and distributeEveryExecutor="false"
 
and  `fitParam.0.jobName`="worker"
and  `fitParam.0.taskIndex`="0"
 
and  `fitParam.1.jobName`="worker"
and  `fitParam.1.taskIndex`="1"
 
and  `fitParam.2.jobName`="ps"
and  `fitParam.2.taskIndex`="0"
 
 
and `systemParam.pythonPath`="python"
and `systemParam.pythonVer`="2.7"
;
```

我们看到，只要配置一个 python 脚本，然后通过 fitParam 指定每个节点的 jobName， taskIndex 即可。

在 python 脚本中，你可以通过如下方式拿到这些参数：

```python
jobName = param("jobName", "worker")
taskIndex = int(param("taskIndex", "0"))
clusterSpec = json.loads(mlsql.internal_system_param["clusterSpec"])
checkpoint_dir = mlsql.internal_system_param["checkpointDir"]
```

一个大致的 TF 脚本如下：

```python
def run():
    # create the cluster configured by `ps_hosts' and 'worker_hosts'
    cluster = tf.train.ClusterSpec(clusterSpec)
 
    # create a server for local task
    server = tf.train.Server(cluster, job_name=jobName,
                             task_index=taskIndex)
 
    if jobName == "ps":
        server.join()  # ps hosts only join
    elif jobName == "worker":
       .......
```

当然，不可避免的，你可能需要用到 MonitoredTrainingSession 等和集群相关的 API。

### 难点
这个需求我昨天早上提出，下午开始弄，我一开始以为一个下午就能搞定，但是最后还是做到了晚上十一点多，这里有几个问题需要注意：

1. 用户可能取消任务，如何及时的杀掉TF cluster.
2. spark 可能异常退出，如何保证也能退出TF cluster
3. 如何区别对待 PS/Worker 角色

### 实现方式
worker 需要能够和 driver 进行交互。为什么呢？TF 启动 Cluster 的时候，是需要 ClusterSpec，也就是每个节点 host 和 port。
Spark 在分发 Task 的时候是并行的，你不知道会分发到哪个节点，并且分发后，你也不知道TF能够在对应的节点获取到哪个端口。为了完成这些信息的收集，需要走如下几个流程：

1. 每个 Task 在启动 TF Server 之前，需要先获取端口，并且占用住，然后上报给 Driver，Driver 会记住这些。

2. 接着 Task 会等待所有的 Task 都上报完成，然后释放占用的端口，启动对应的 TF Server。
TF Server 完成训练后会上报 Driver。

3. PS 会监听是不是所有的 Worker 都已经完成了工作，如果是，则会自己把自己结束掉。

4. 最后整个训练结束，并且把训练好的模型发送到 HDFS 上。

Executor 和 Driver 交互，其实 Byzer 里已经实现了自己的 PRC 层。不过因为这次比较简单，只需要单向通讯即可，所以直接基于 Driver 的 http 接口完成。