# 使用 window / watermark 

Window/watermark 是流式计算里特有的概念，下面是一个具体的使用模板：

```sql
set streamName="streamExample-1218";

-- 连接 mysql 作为数据接收器
-- 相应地修改 mysql 连接字符串 
connect jdbc where  
driver="com.mysql.jdbc.Driver"
and url="jdbc:mysql://127.0.0.1:13306/notebook?useSSL=false"
and driver="com.mysql.jdbc.Driver"
and user="root"
and password="mlsql"
as mysql1;


-- 模拟数据
set data='''
{"key":"a","value":"no","topic":"test","partition":0,"offset":0,"timestamp":"2008-01-24 18:01:01.001","timestampType":0}
{"key":"a","value":"no","topic":"test","partition":0,"offset":1,"timestamp":"2008-01-24 18:01:02.002","timestampType":0}
{"key":"b","value":"no","topic":"test","partition":0,"offset":2,"timestamp":"2008-01-24 18:01:03.003","timestampType":0}
{"key":"c","value":"no","topic":"test","partition":0,"offset":3,"timestamp":"2008-01-24 18:01:04.003","timestampType":0}
{"key":"d","value":"no","topic":"test","partition":0,"offset":4,"timestamp":"2008-01-24 18:01:05.003","timestampType":0}
{"key":"d","value":"no","topic":"test","partition":0,"offset":5,"timestamp":"2008-01-24 18:01:06.003","timestampType":0}
''';

-- 将数据加载成表
load jsonStr.`data` as datasource;

-- 将表转化为流式数据源
load mockStream.`datasource` options 
stepSizeRange="0-3"
as newkafkatable1;

-- 聚合
select cast(key as string) as k, timestamp AS ts from newkafkatable1 as table21;

-- 为 table21 注册 watermark
register WaterMarkInPlace.`table21` as tmp_1
options eventTimeCol="ts"
and delayThreshold="2 seconds";

-- 处理 table1
select k, count(*) as num from table21
group by k, window(ts,"3 seconds","1 seconds")
as table22;

-- 将数据保存至 mysql.
save append table22 
as streamJDBC.`mysql1.test1` 
options mode="Complete"
and `driver-statement-0`="create table if not exists test2(k TEXT,c BIGINT)"
and `statement-0`="insert into notebook.test2(k,c) values(?,?)"
and duration="3"
and checkpointLocation="/tmp/cpl1218";
```

```register WaterMarkInPlace``` 在表 table21 设置 Watermark, eventTime 字段为 ts , Watermark 容忍的延迟为 2 秒。例子中, 
假设当前 Watermark 为 18:01:05 时, 一条 ts = 18:01:02 数据到达，但会被丢弃。 

```group by k, window(ts, "3 seconds","1 seconds" )``` 表示根据 ts 字段为时间窗口，每个窗口 3 秒， 滑窗 1 秒，说明如下

| 时间窗口    | 开始时间  | 结束时间| 消息 key |
|---------|---|---|--------|
| window1 | 18:01:00 | 18:01:03| a      |
| window2 | 18:01:02 | 18:01:05| a b c  |
| window3 | 18:01:04 | 18:01:07| c d    |

