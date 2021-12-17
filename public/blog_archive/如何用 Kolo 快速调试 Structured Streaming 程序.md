## 如何用 Byzer 快速调试 Structured Streaming 程序
### 前言
早上对 Structured Streaming 的 window 函数，Output Mode 以及 Watermark 有些疑惑的地方。Structured Streaming 的文档偏少，而且网上的文章同质化太严重，基础的不能再基础了，但是我也不想再开个测试的工程项目，所以直接就给予 Byzer 来调试。

### 本地启动一个
根据 streamingpro 的文档，在本地启动一个 local 模式的实例，然后打开 127.0.0.1:9003 页面。

### 测试过程
首先设置一个应用名称。通过

```sql
set streamName="streamExample";
```

来完成.

接着造一些数据：

```sql
-- mock some data.
set data='''
{"key":"1","value":"no","topic":"test","partition":0,"offset":0,"timestamp":"2008-01-24 18:01:01.001","timestampType":0}
{"key":"2","value":"no","topic":"test","partition":0,"offset":1,"timestamp":"2008-01-24 18:01:18.002","timestampType":0}
{"key":"3","value":"no","topic":"test","partition":0,"offset":2,"timestamp":"2008-01-24 18:01:20.003","timestampType":0}
{"key":"4","value":"no","topic":"test","partition":0,"offset":3,"timestamp":"2008-01-24 18:01:50.003","timestampType":0}
{"key":"5","value":"no","topic":"test","partition":0,"offset":4,"timestamp":"2008-01-24 18:02:01.003","timestampType":0}
{"key":"6","value":"no","topic":"test","partition":0,"offset":5,"timestamp":"2008-01-24 18:02:01.003","timestampType":0}
''';
```

这里精心调整下 timestamp 的实验，因为后面那我们测试都是根据这个时间来完成的。

把这些数据模拟成数据源表，我们取名叫 newkafkatable1。

```sql
-- load data as table
load jsonStr.`data` as datasource;
 
-- convert table as stream source
load mockStream.`datasource` options 
stepSizeRange="0-3"
as newkafkatable1;
```
 
stepSizeRange 表示每个批次随机会给 0 - 3 条数据。你也可用 fixSize 参数，这样可以控制每个批次每次给多条。
接着对数据做个简单的处理。

```sql
select cast(key as string) as k, timestamp  from newkafkatable1 
as table21;
```

对 table2 设置一下 WaterMark

```sql
register WaterMarkInPlace.`table21` as tmp1
options eventTimeCol="timestamp"
and delayThreshold="60 seconds";
```

按窗口进行聚合，聚合的窗口大小是 20 秒。

```sql
select collect_list(k),
window(timestamp,"20 seconds").start as start,
window(timestamp,"20 seconds").end as end
from table21 
group by window(timestamp,"20 seconds")
as table22;
```

最后启动该流程序：

```sql
save append table22  
as console.`` 
options mode="Complete"
and duration="10"
and checkpointLocation="/tmp/cpl4";
```

这里采用 Complete 模式，然后输出打印在 console.

我分别尝试了 Complete，Append，Update 模，然后调整 WarterMark，以及测试数据的 timestamp，然后观察情况。

观察完毕，你可以关掉这个流式程序，按住 command 键点击任务列表，会新开一个窗口，点击关闭任务按钮即可。

因为 Console 输出不支持从 checkpoint recover ，所以你可以手动删除 /tmp/cpl4 目录。

接着你修改 Byzer 脚本，然后点击提交即可。

### 总结
通过完全校本化，界面操作，以及 mock 数据的支持，可以很方便你进行 structured streaming 的探索。

