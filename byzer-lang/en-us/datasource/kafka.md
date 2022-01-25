# Kafka

Byzer supports Kafka as a streaming data source or as a normal data source for AdHoc loading. Both have superior performance.

This chapter only covers data loading. For more information, see [Processing Streaming Data with Byzer](/byzer-lang/en-us/streaming/README.md).


## Streaming loading

> **Note:** Byzer supports Kafka `0.10` or above.

To streaming load the data source, you need to use `kafka` keywords and specify the server address through the parameter `kafka.bootstrap.servers`, as shown in the following example:

```sql
> LOAD kafka.`$topic_name` OPTIONS
  `kafka.bootstrap.servers`="${your_servers}"
  AS kafka_post_parquet;
```

## AdHoc loading

To load the data source with AdHoc, you need to use `AdHoc` keywords and specify the server address through the parameter `kafka.bootstrap.servers` , as shown in the following example:

```
> LOAD adHocKafka.`$topic_name` WHERE
  kafka.bootstrap.servers="${your_servers}"
  and multiplyFactor="2"
  AS table1;

> SELECT count(*) FROM table1 WHERE value LIKE "%yes%" AS output;
```
`multiplyFactor` means to set two threads to scan the same partition and at the same time increase the degree of parallelism by two times for speeding up.

Byzer also provides some advanced parameters to specify ranges which come in groups:

**Time**

`timeFormat`: specify the date format
`startingTime`: specify the start time
`endingTime`: specify the end time

**Offset**

`staringOffset`: specify the starting sector
`staringOffset`: specify the ending sector

> Through offset, you need to specify the starting and ending sectors of each partition, which is more troublesome and less used.
