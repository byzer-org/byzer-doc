# Delta load, store and streaming support

Delta is essentially a directory in HDFS. This means that you can work with your home directory. We will introduce the use of Delta in the following sections:

1. Basic use
2. Use by database table schema
3. Support for Upsert semantics
4. Streaming update support
5. Small files merge
6. Simultaneously load multi-version data into one table
7. View the status of tables (such as the number of files, etc.)

### Basic use

```sql
set rawText='''
{"id":1,"content":"MLSQL is a good language","label":0.0},
{"id":2,"content":"Spark is a good language","label":1.0}
{"id":3,"content":"MLSQL language","label":0.0}
{"id":4,"content":"MLSQL is a good language","label":0.0}
{"id":5,"content":"MLSQL is a good language","label":1.0}
{"id":6,"content":"MLSQL is a good language","label":0.0}
{"id":7,"content":"MLSQL is a good language","label":0.0}
{"id":8,"content":"MLSQL is a good language","label":1.0}
{"id":9,"content":"Spark good language","label":0.0}
{"id":10,"content":"MLSQL is a good language","label":0.0}
''';

load jsonStr.`rawText` as orginal_text_corpus;

save append orginal_text_corpus as delta.`/tmp/delta/table10`;
```

By executing above statements, we can successfully write the relevant data into the Delta data lake.

The way to load is as follows:

```sql
load delta.`/tmp/delta/table10` as output;
```

### Use by database table schema

Many users don't want to use paths and they want to use the data lake like using Hive. Byzer-lang also provides support for this. At startup, add the parameter.

```
-streaming.datalake.path /tmp/datahouse
```

> By default, `/tmp/datahouse` is the local directory. If `$SPARK_HOME/conf` contains HDFS configuration files, `/tmp/datahouse` refers to the HDFS directory; the same method can also be used to support object storage such as OSS.
>
> Please create the directory `/tmp/datahouse` first.

The system then operates in a data lake mode. At this time, users cannot write the path by himself but needs to use it in the mode of `db.table`.

Save data lake table:

```sql
select 1 AS id, 'abc' AS address
UNION ALL
SELECT 2 AS id, 'def' AS address
AS table_1;

save overwrite table_1 as delta.`default.table_1` partitionBy id;
```

Load the data lake table:

```sql
load delta.`default.table_1` as output;
```

You can view all databases and tables with the following command:

```sql
!delta show tables;
```

### Support for Upsert semantics

Delta supports the Upsert operation of data, and the corresponding semantics are: if it exists, update it; if it does not exist, add it.

We saved ten pieces of data earlier and now execute the following code:

```sql
set rawText='''
{"id":1,"content":"I updated this data","label":0.0}
''';

load jsonStr.`rawText` as orginal_text_corpus;

save append orginal_text_corpus
as delta.`/tmp/delta/table10`
and idCols="id";
```
You can see that the data with id 1 has been updated to .

![](http://docs.mlsql.tech/upload_images/WX20190819-192447.png)


### Streaming update support

This section briefly involves the writing of streaming programs. You can get a sense of it. For more information, read streaming chapters.

In order to complete this example, users may need to start a Kafka locally and the version is above 0.10.0.

First, we write some data to Kafka via Byzer-lang:

```sql
set abc='''
{ "x": 100, "y": 201, "z": 204 ,"dataType":"A group"}
''';
load jsonStr.`abc` as table1;

select to_json(struct(*)) as value from table1 as table2;
save append table2 as kafka.`wow` where
kafka.bootstrap.servers="127.0.0.1:9092";
```

Then start a streaming program to consume:

```sql
-- the stream name, should be uniq.
set streamName="kafkaStreamExample";

!kafkaTool registerSchema 2 records from "127.0.0.1:9092" wow;

-- convert table as stream source
load kafka.`wow` options
kafka.bootstrap.servers="127.0.0.1:9092"
and failOnDataLoss="false"
as newkafkatable1;

-- aggregation
select *  from newkafkatable1
as table21;

-- output the the result to console.
save append table21  
as rate.`/tmp/delta/wow-0`
options mode="Append"
and idCols="x,y"
and duration="5"
and checkpointLocation="/tmp/s-cpl6";
```

Here, we specify `x, y` as the composite key.

Now we can view:

```sql
load delta.`/tmp/delta/wow-0` as show_table1;
select * from show_table1 where x=100 and z=204 as output;
```

### Small files merge

Byzer-lang has strict requirements for Delta's small files merging. It must be in append mode. You can use samll files merge to add data but not to update data.

We simulate some Kafka data in the example:

```sql
set data='''
{"key":"a","value":"no","topic":"test","partition":0,"offset":0,"timestamp":"2008-01-24 18:01 :01.001","timestampType":0}
{"key":"a","value":"no","topic":"test","partition":0,"offset":1,"timestamp":"2008-01-24 18:01 :01.002","timestampType":0}
{"key":"b","value":"no","topic":"test","partition":0,"offset":2,"timestamp":"2008-01-24 18:01 :01.003","timestampType":0}
{"key":"b","value":"no","topic":"test","partition":0,"offset":3,"timestamp":"2008-01-24 18:01 :01.003","timestampType":0}
{"key":"b","value":"no","topic":"test","partition":0,"offset":4,"timestamp":"2008-01-24 18:01 :01.003","timestampType":0}
{"key":"b","value":"no","topic":"test","partition":0,"offset":5,"timestamp":"2008-01-24 18:01 :01.003","timestampType":0}
''';
```

Then streaming write:

```sql
-- the stream name, should be uniq.
set streamName="streamExample";

-- load data as table
load jsonStr.`data` as datasource;

-- convert table as stream source
load mockStream.`datasource` options
stepSizeRange="0-3"
as newkafkatable1;


select *  from newkafkatable1
as table21;

-- output the the result to console.
save append table21  
as rate.`/tmp/delta/rate-1-table`
options mode="Append"
and duration="10"
and checkpointLocation="/tmp/rate-1" partitionBy key;
```

Note: Delta in the stream is called rate.

Now we use the tool !delta to view the existing version:

```sql
!delta history /tmp/delta/rate-2-table;
```

The content is as follows:

![](http://docs.mlsql.tech/upload_images/1063603-e43fba9ba7a22149.png)

Now we can merge the data before the specified version:

```
!delta compact /tmp/delta/rate-2-table 8 1;
```

This command means that all data before the eighth version is merged and each directory (partition) is merged into a file.

Let's take a look at files in each partition before merging:

![](http://docs.mlsql.tech/upload_images/1063603-98a05bf000790a02.png)

Merged files:

![](http://docs.mlsql.tech/upload_images/1063603-ba9292b2146633f1.png)

We deleted 16 files and generated two new files. In addition, during compaction, it does not affect reading and writing. So it is very useful.

### Simultaneously load multi-version data into one table

Delta supports multiple versions and we can also load a version within the range at one time. For example, in the following example, load Delta [12-14) version of data as a table. Then users can do group by according to id to get multiple versions of data in one row.

```sql
set a="b";

load delta.`/tmp/delta/rate-3-table` where
startingVersion="12"
and endingVersion="14"
as table1;

select __delta_version__, collect_list(key), from table1 group by __delta_version__,key
as table2;
```

### View the status of tables

```sql
!delta info scheduler.time_jobs;
```

