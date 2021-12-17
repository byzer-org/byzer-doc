# Byzer-lang Kafka小工具集锦

流式程序的一大特点就是调试没有批那么方便。为此，我们提供一些工具方便用户探索 Kafka 里的数据：

## 查看 Kafka 最新 N 条数据
```sql
!kafkaTool sampleData 10 records from "127.0.0.1:9092" my-topic;
```

这个命令表示我要采集 10 条数据，来源是 Kafka 集群"127.0.0.1:9092"，主题( topic ) 是wow。
![kafka-SampleData](./kafka-sampleData.PNG)

## 自动推测Kafka的Schema

```sql
!kafkaTool schemaInfer 10 records from "127.0.0.1:9092" my-topic;
```

句法格式和前面一致，唯一区别是换了个命令，把sampleData换成schemaInfer. 目前只支持 Kafka json格式的消息。

## 查看流式程序的checkpoint目录的最新offset

```sql
!kafkaTool streamOffset /tmp/ck;
```