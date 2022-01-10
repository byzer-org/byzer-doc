# 如何实现Spark过载保护

### 前言

因为我司将Spark大规模按Service模式使用，也就是Spark实例大多数是7*24小时服务的，然后接受各种ad-hoc查询。通常最难受的就是被bad query 给拖死了，然后导致服务不可用。那么有没有办法让Spark意识到危险时，及时止损，杀掉那个可能引起自己奔溃的query? 如果能做到那么价值会很大。我们可以将将对应的query发给Spark实例的构建者以及对应的使用者，并且附带上一些实例运行对应query的信息，这样可以有效的让双方沟通，优化查询。

### 实现思路

肯定不能拍脑袋，毕竟这是一个复杂的事情，否则早就应该有非常成熟的工具出来了。我这里也仅仅是最近两天的思考，抛砖引玉，和大家一起探讨。

我拍脑袋的觉得，Spark挂掉常见的一般也就两情况：

1. Spark Driver 没有catch到的特定异常，然后导致spark context关闭，最后停止正常服务。
2. Shuffle 导致应用挂掉。

其中Shuffle导致应用挂掉主要体现在：

1. Executor Full GC，driver 以为 Executor 挂掉杀掉他，或者其他节点到这个节点拉数据，半天拉不动，然后connection reset。
2. Executor 真的就 crash 了，因为占用内存过大。
3. OOM，这个是 shuffle 申请内存时申请不到了，会发生，所以Spark自带的OOM

然后因为超出 Yarn 内存限制的被杀，我们不做考虑。

其实 Shuffle 出现问题是 Spark 实例出现问题的主要原因。而导致 Shuffle 出现问题的原因则非常多，最常见的是数据分布不均匀。对此，我们的监控思路也就有了：

1. 设置一个定时器，比如 2s 采集数据一次
2. 采集的数据大致格式为 groupId，executorId，shuffleRead， shuffleWrites, 其中 groupId 为某一组 job(比如 MLSQL 就是一个大脚本，每个脚本的任务都会有一个唯一的 groupId)。采集的内容含义是，当前 groupId 涉及到的job已经长生的所有 shuffle 指标的快照。两条数据相减，就是shuffle在某N个周期内的增量情况。shuffle 包括 bytes 和 records 以及 diskSpill 三个维度。

首先我们考虑，一个 Bad Query 对 Spark 实例的危害性来源于对 Executor 的直接伤害。所以我们首先要计算的是每个Executor危险指数。

根据上面的数据，我么可以计算 Executor 危害性的四个因子：

1. 计算 shuffle 在在当前 executor 的非均衡程度，我们暂且称之为非均衡指数。指数越高，情况越不妙。
2. shuffle 速率，也就是每秒增长量。shuffle 速率越低，则表示 executor 可能负载太高，出问题的概率就高。
3. shuffle bytes/ shuffle records 单记录大小，单记录越大，危险性越高。
4. 当前 executor GC 情况。单位时间 GC 时间越长，危险性越高。

现在我们得到一个公式：

```text
危险指数 = a * 非均衡指数 - b * shuffle 速率 + c * 单记录大小 + d * gctime/persecond
```

因为本质上这几个因子值互相是不可比的，直接相加肯定是有问题的。我们给了一个权重系数，同时我们希望这几个因子尽可能可以归一到(0-1)。具体优化方式如下：

1. 非均衡指数大概率可以归到(0-1)
2. shuffle速率我们可以取一个取一个最大值（经验），从而将其归一到(0-1)
3. 单记录大小我们也规定一个最大值。
4. gctime/persecond 肯定会是 (0,1)

所以最后的公式是：



```text
某个job组对某个executor危险指数 = a*非均衡指数 
          - b*shuffle速率/最大速率 
          + c*单记录大小/单记录最大值 
          + d*gctime/persecond
```



其中 非均衡指数 = (shuffle r/w in executor - 平均 shuffle r/w) / (平均 shuffle r/w * ![[公式]](https://www.zhihu.com/equation?tex=%5Cgamma) )

说明：

1. 当非均衡指数值为负数，则设置为0,当均衡指数大于1时，归为1.
2. γ 为经验值。也就是一个executor的shuffle负载小于平均值的多少倍时，我们认为还是能接受的。
3. 我们需要设定一个shuffle绝对数据量的阈值，然后才对executor进行危险指数计算。譬如shuffle量大于1g,之后才开启指数计算。

a,b,c,d 的值如何确定呢？因为在系统挂掉之前，我们的数据采集系统都会勤勤恳恳工作，找到这些让系统挂掉的查询，然后分别计算上面四个指数，然后得到一个最好的线性拟合即可。

上面是针对每个executor危险系数计算。实际上，整个集群的安危取决于每一个executor是不是能扛过去。理论上A Executor扛不过去，B因为具有相同的资源配置，也会抗不过去，所以Bad Query最大的问题是会弄成连锁反应，慢慢搞掉所有Executor. 所以我个人认为只要有一个executor的危险指数过高，就应该终止Query。

同时，我们既可以监控全局的executor shuffle数据计算集群危险指数，来确定集群是不是有危险，一旦有危险，计算每个groupId的危险指数，然后杀掉topN危险指数最高的任务从而是集群度过危险。分级计算可以保证我们计算的足够快，同时也避免每个groupId的任务都是OK的，但是因为任务太多而导致的问题。

### 额外

还有一个监控executor的变化情况，如果发现有N个executor短时被杀掉，那么可以考虑终止当前所有query. 这可能会是一个简单又会有效的方式。