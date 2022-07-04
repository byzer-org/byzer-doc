# 加载 MockStream 流式数据源

Byzer 显示的支持 MockStream。它可以用来模拟数据源，广泛应用于测试场景中。

本章只介绍数据加载，想了解更多流式编程细节，请查看 [使用 Byzer 处理流数据](/byzer-lang/zh-cn/streaming/README.md)。

### 模拟输入数据源

下面是个简单的例子：

```sql
-- 模拟数据
> SET data='''
{"key":"yes","value":"no","topic":"test","partition":0,"offset":0,"timestamp":"2008-01-24 18:01:01.001","timestampType":0}
{"key":"yes","value":"no","topic":"test","partition":0,"offset":1,"timestamp":"2008-01-24 18:01:01.002","timestampType":0}
{"key":"yes","value":"no","topic":"test","partition":0,"offset":2,"timestamp":"2008-01-24 18:01:01.003","timestampType":0}
{"key":"yes","value":"no","topic":"test","partition":0,"offset":3,"timestamp":"2008-01-24 18:01:01.003","timestampType":0}
{"key":"yes","value":"no","topic":"test","partition":0,"offset":4,"timestamp":"2008-01-24 18:01:01.003","timestampType":0}
{"key":"yes","value":"no","topic":"test","partition":0,"offset":5,"timestamp":"2008-01-24 18:01:01.003","timestampType":0}
''';

-- 将数据加载成表
> LOAD jsonStr.`data` as datasource;

-- 将表转化成流式数据源
> LOAD mockStream.`datasource` options
  stepSizeRange="0-3"
  AS newkafkatable1;
```
`stepSizeRange` 控制每个周期发送的数据条数，例子中 `0-3` 代表 0 到 3 条数据。