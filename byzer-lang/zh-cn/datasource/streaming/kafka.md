# 加载 Kafka 流式数据源 

Byzer 显示的支持 Kafka 作为流式数据源，也支持将其作为普通数据源进行 AdHoc 加载，性能同样可观。

本章只介绍数据加载，想了解更多流式编程细节，请查看 [使用 Byzer 处理流数据](/byzer-lang/zh-cn/streaming/README.md)。


### 1. 流式加载

>**注意：** Byzer 支持 `0.10` 以上 Kafka 版本

流式加载数据源，需要使用 `kafka` 关键字，并通过 `kafka.bootstrap.servers` 参数指定服务器地址，如下示例：

```sql
> LOAD kafka.`$topic_name` OPTIONS
  `kafka.bootstrap.servers`="${your_servers}"
  AS kafka_post_parquet;
```

### 2. AdHoc加载

AdHoc 加载数据源，需要使用 `AdHoc` 关键字，并通过 `kafka.bootstrap.servers` 参数指定服务器地址，如下示例：

```
> LOAD adHocKafka.`$topic_name` WHERE 
  kafka.bootstrap.servers="${your_servers}"
  and multiplyFactor="2" 
  AS table1;
  
> SELECT count(*) FROM table1 WHERE value LIKE "%yes%" AS output;
```
`multiplyFactor` 代表设置两个线程扫描同一个分区，同时提升两倍的并行度，加快速度。

Byzer 还提供一些高级参数来指定范围，它们是成组出现的：

**通过时间**

`timeFormat：`指定日期格式
`startingTime：`指定开始时间
`endingTime：`指定结束时间

**通过offset**

`staringOffset：`指定起始位置
`staringOffset：`指定结束位置

> 通过offset需要指定每个分区的起始结束，比较麻烦，使用较少。
