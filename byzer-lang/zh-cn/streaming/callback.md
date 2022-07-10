# 设置流式计算回调

### 1. 查看流计算进度
用户可以通过特定的命令查看一个流式程序的进度：

```sql
!show progress/streamExample;
```

这里, streamExample 为流式任务名称，启动时设置，例如```set streamName="streamExample" ```
如果你忘记了自己流程序的名字，那么可以使用下面命令获得列表。

```sql
!show jobs;
```

### 2. HTTP 回调
如果我想收集一个流程序什么时候开始，运行的状态，以及如果异常或者被正常杀死的事件，可以使用回调，具体使用方式如下：

```sql
-- 为流式数据源取名，不可重名
set streamName="streamExample";

-- 模拟数据
set data='''
{"key":"yes","value":"no","topic":"test","partition":0,"offset":0,"timestamp":"2008-01-24 18:01:01.001","timestampType":0}
{"key":"yes","value":"no","topic":"test","partition":0,"offset":1,"timestamp":"2008-01-24 18:01:01.002","timestampType":0}
{"key":"yes","value":"no","topic":"test","partition":0,"offset":2,"timestamp":"2008-01-24 18:01:01.003","timestampType":0}
{"key":"yes","value":"no","topic":"test","partition":0,"offset":3,"timestamp":"2008-01-24 18:01:01.003","timestampType":0}
{"key":"yes","value":"no","topic":"test","partition":0,"offset":4,"timestamp":"2008-01-24 18:01:01.003","timestampType":0}
{"key":"yes","value":"no","topic":"test","partition":0,"offset":5,"timestamp":"2008-01-24 18:01:01.003","timestampType":0}
''';

-- 将数据加载成表
load jsonStr.`data` as datasource;

-- 将表转化为流式数据源
load mockStream.`datasource` options 
stepSizeRange="0-3"
as newkafkatable1;

-- aggregation 
select cast(key as string) as k,count(*) as c  from newkafkatable1 group by key
as table21;

-- run command as  MLSQLEventCommand.`` where
--       eventName="started,progress,terminated"
--       and handleHttpUrl="http://127.0.0.1:9002/jack"
--       and method="POST"
--       and params.a=""
--       and params.b="";
!callback post "http://127.0.0.1:9002/api_v1/test" when "started,progress,terminated";
-- output the the result to console.

save append table21  
as console.`` 
options mode="Complete"
and duration="15"
and checkpointLocation="/tmp/cpl14";
```
核心关键点是：

```sql
!callback post "http://127.0.0.1:9002/api_v1/test" when "started,progress,terminated";
```

这个表示如果发生 started, progress, terminated 三个事件中的任何一个，都以 HTTP POST 协议上报给 http://127.0.0.1:9002/api_v1/test 接口。
