# MySQL Binlog synchronization

MySQL is widely used. A core point of the data warehouse is to synchronize the business database (offline or real-time) to the data warehouse. Offline mode is direct full synchronization so it is simple.
Override and real-time mode is slightly more complicated. Process:

```
MySQL -> Cannel (or some other tools) -> Kafka ->

Streaming engine -> Hudi (HBase) and other tools that can provide update storage ->

Synchronize or dump -> provide external services  
```

This is a very cumbersome process. The longer the process, the higher the error probability. And it is more difficult for us to debug. Byzer-lang provides a very simple solution:

```sql
MySQL -> Byzer-lang -> Delta(HDFS)
```

Users' only job is to write a Byzer-lang program and run on the Notebook.

The whole script contains only two pieces of code, Load and Save, which is very simple.

Here is the Load statement:

```sql
set streamName="binlog";

load binlog.`` where
host="127.0.0.1"
and port="3306"
and userName="xxx"
and password="xxxx"
and bingLogNamePrefix="mysql-bin"
and binlogIndex="4"
and binlogFileOffset="4"
and databaseNamePattern="mlsql_console"
and tableNamePattern="script_file"
as table1;
```

`set streamName` indicates it is a stream script and the name of the stream program is binglog.
As we learned before, the load statement can load any stored data or data in any format as a table. Here, we load the logs of MySQL binglog as a table.

There are two main groups of parameters. The first group is related to binglog:

1. `bingLogNamePrefix`: prefix for MySQL binglog configuration; you can ask DBA to get it.
2. `binlogIndex`: which binglog to consume from
3. `binlogFileOffset`: which position of single binlog file to consume from

`binlogFileOffset` can't specify the position arbitrarily because it is binary and the position jumps. `4` represents the starting position of a `binlogFileOffset` and is a special number.
If users do not want to start from the starting position, then users can consult DBA or find a reasonable position by yourself with the following command:

```shell
mysqlbinlog \
--start-datetime="2019-06-19 01:00:00" \
--stop-datetime="2019-06-20 23:00:00" \
--base64-output=decode-rows \
-vv  master-bin.000004
```

If an inappropriate location is arbitrarily specified, the result is that data cannot be consumed and then incremental synchronization cannot be achieved.

The second set of parameters is to filter which tables of which databases need to be synchronized:

1. databaseNamePattern: the regular expression for db filtering
2. tableNamePattern: the regular expression for table name filtering

Now we have `table1` that contains binlog. We need to synchronize data to the Delta table with `table1`. 

Note: we synchronize data instead of synchronizing binlog itself. We will continuously update `table1` into Delta. 

The specific code is as follows:


```sql
save append table1
as rate.`mysql_{db}.{table}`
options mode="Append"
and idCols="id"
and duration="5"
and syncType="binlog"
and checkpointLocation="/tmp/cpl-binlog2";
```

We will explain each parameter.

`db` and `table` in`mysql_{db}.{table}`  are placeholders. Because we will synchronize multiple tables of many databases at one time, if all are manually specified, it will be very cumbersome and inefficient. Byzer-lang's rate data source allows us to replace by placeholders.

`idCols`: this parameter has been mentioned in the previous chapter on Delta. `idCols` requires users to specify a set of composite keys so that Byzer-lang can complete Upsert semantics.

`syncType`: what we are synchronizing is binlog , so that the specific operations of binlog will be performed.

`duration` and `checkpointLocation`: they are unique to streaming computing. They respectively indicate the running period and the location of running logs.

We have now achieved our goal of syncing arbitrary tables into the Delta data lake!

Currently Binlog synchronization has some limitations:

1. MySQL needs to configure `binlog_format=Row.`. Of course this is the default setting theoretically.
2. It only supports synchronization of update/delete/insert actions in binlog. If the database table structure is modified, the synchronization will fail by default and users need to perform full synchronization again before performing the incremental synchronization.
   If you want to continue running, you can set `mergeSchema="true"` in the save statement.
3. If different tables have different primary key columns (different `idCols` need to be configured), then multiple streaming synchronization scripts may be required.

### Common error

If it keeps appearing:

```
Trying to restore lost connection to .....
Connected to....
```

Then check whether the parameter `server_id`  in MySQL's `my.cnf` is configured.
