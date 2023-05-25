# 写入 Delta Lake

### 将表写入 Delta Lake

```sql
save append orginal_text_corpus as delta.`test_demo.table1`;
```

###  Upsert 语义的支持

Delta 支持数据的 Upsert 操作，对应的语义为： 如果存在则更新，不存在则新增。

我们前面保存了十条数据，现在尝试如下代码：

```sql
set rawText='''
{"id":1,"content":"我更新了这条数据","label":0.0}
''';

load jsonStr.`rawText` as orginal_text_corpus;

save append orginal_text_corpus  
as delta.`/tmp/delta/table10` 
and idCols="id";
```
我们看到 id 为 1 的数据已经被更新为。

![](/byzer-lang/zh-cn/datasource/dw/images/data_lake_1.png)


### 流式更新支持

这里，我们会简单涉及到流式程序的编写，在后续专门的 [流式章节](/byzer-lang/zh-cn/streaming/README.md) 会提供更详细的解释和说明。

为了完成这个例子，用户可能需要在本机启动一个 Kafka，并且版本是 0.10.0 以上。

首先，我们通过 Byzer-lang 写入一些数据到 Kafka:

```sql
set abc='''
{ "x": 100, "y": 201, "z": 204 ,"dataType":"A group"}
''';
load jsonStr.`abc` as table1;

select to_json(struct(*)) as value from table1 as table2;
save append table2 as kafka.`wow` where 
kafka.bootstrap.servers="127.0.0.1:9092";
```

接着启动一个流式程序消费：

```sql
-- 为流式数据源取名，不可重名
set streamName="kafkaStreamExample";

!kafkaTool registerSchema 2 records from "127.0.0.1:9092" wow;

-- 将表转换为流式数据源
load kafka.`wow` options 
kafka.bootstrap.servers="127.0.0.1:9092"
and failOnDataLoss="false"
as newkafkatable1;

-- 聚合
select *  from newkafkatable1
as table21;

-- 将结果输出至 console
save append table21  
as rate.`/tmp/delta/wow-0` 
options mode="Append"
and idCols="x,y"
and duration="5"
and checkpointLocation="/tmp/s-cpl6";
```

这里，我们指定 x,y 为联合主键。

现在可以查看了：

```sql
load delta.`/tmp/delta/wow-0` as show_table1;
select * from show_table1 where x=100 and z=204 as output;
```



### 小文件合并

Byzer-lang 对 Delta 的小文件合并的要求比较苛刻，要求必须是追加（append ）模式，Upsert 模式不能进行小文件合并。

我们在示例中模拟一些 Kafka 的数据：

```sql
set data='''
{"key":"a","value":"no","topic":"test","partition":0,"offset":0,"timestamp":"2008-01-24 18:01:01.001","timestampType":0}
{"key":"a","value":"no","topic":"test","partition":0,"offset":1,"timestamp":"2008-01-24 18:01:01.002","timestampType":0}
{"key":"b","value":"no","topic":"test","partition":0,"offset":2,"timestamp":"2008-01-24 18:01:01.003","timestampType":0}
{"key":"b","value":"no","topic":"test","partition":0,"offset":3,"timestamp":"2008-01-24 18:01:01.003","timestampType":0}
{"key":"b","value":"no","topic":"test","partition":0,"offset":4,"timestamp":"2008-01-24 18:01:01.003","timestampType":0}
{"key":"b","value":"no","topic":"test","partition":0,"offset":5,"timestamp":"2008-01-24 18:01:01.003","timestampType":0}
''';
```

接着流式写入：

```sql
-- 为流式数据源取名，不可重名
set streamName="streamExample";

-- 将数据加载成表
load jsonStr.`data` as datasource;

-- 将表转化成流式数据源
load mockStream.`datasource` options 
stepSizeRange="0-3"
as newkafkatable1;


select *  from newkafkatable1 
as table21;

-- 将结果输出至 console.
save append table21  
as rate.`/tmp/delta/rate-1-table`
options mode="Append"
and duration="10"
and checkpointLocation="/tmp/rate-1" partitionBy key;
```

这里注意一下是流里面 Delta 叫 rate。

现在我们利用宏命令  `!delta` 查看已有的版本：

```sql
!delta history /tmp/delta/rate-2-table;
```

内容如下：

![](/byzer-lang/zh-cn/datasource/dw/images/data_lake_2.png)

现在我们可以对指定版本之前的数据做合并了：

```sql
!delta compact /tmp/delta/rate-2-table 8 1;
```

这条命令表示对第八个版本之前的所有数据都进行合并，每个目录（分区）都合并成一个文件。

我们看下合并前每个分区下面文件情况：

![](/byzer-lang/zh-cn/datasource/dw/images/data_lake_3.png)

合并后文件情况：

![](/byzer-lang/zh-cn/datasource/dw/images/data_lake_4.png)

我们删除了16个文件，生成了两个新文件。另外在compaction的时候，并不影响读和写。所以是非常有用的。


