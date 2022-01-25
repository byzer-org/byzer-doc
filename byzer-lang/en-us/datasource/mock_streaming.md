# MockStream

Byzer appears to support for MockStream. It can be used to simulate data sources and is widely used in test scenarios.

This chapter only covers data loading. For more information, see [Processing Streaming Data with Byzer](/byzer-lang/en-us/streaming/README.md).

### Analog input data source

Example:

```sql
-- mock some data.
> SET data='''
{"key":"yes","value":"no","topic":"test","partition":0,"offset":0,"timestamp":"2008-01-24 18:01:01.001","timestampType":0}
{"key":"yes","value":"no","topic":"test","partition":0,"offset":1,"timestamp":"2008-01-24 18:01:01.002","timestampType":0}
{"key":"yes","value":"no","topic":"test","partition":0,"offset":2,"timestamp":"2008-01-24 18:01:01.003","timestampType":0}
{"key":"yes","value":"no","topic":"test","partition":0,"offset":3,"timestamp":"2008-01-24 18:01:01.003","timestampType":0}
{"key":"yes","value":"no","topic":"test","partition":0,"offset":4,"timestamp":"2008-01-24 18:01:01.003","timestampType":0}
{"key":"yes","value":"no","topic":"test","partition":0,"offset":5,"timestamp":"2008-01-24 18:01:01.003","timestampType":0}
''';

-- load data as table
> LOAD jsonStr.`data` as datasource;

-- convert table as stream source
> LOAD mockStream.`datasource` options
  stepSizeRange="0-3"
  AS newkafkatable1;
```
`stepSizeRange` controls the number of pieces of data sent per cycle, in the example `0-3` represents 0 to 3 pieces of data.