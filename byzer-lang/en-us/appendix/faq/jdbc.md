# Common issues about loading JDBC (eg MySQL, Oracle) data
Byzer can use Load syntax to load data sources such as MySQL and Oracle that support the JDBC protocol. Common usage methods are as follows (examples are from [official documentation](/byzer-lang/en-us/datasource/jdbc.md)):

```sql
set user="root";

connect jdbc where
url="jdbc:mysql://127.0.0.1:3306/wow?characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&tinyInt1isBit=false"
and driver="com.mysql.jdbc.Driver"
and user="${user}"
and password="${password}"
as db_1;

load jdbc.`db_1.table1` as table1;
select * from table1 as output;
```

Among them, **connect** doesn't mean to connect to a database. The statement does not perform the real connection action, but only records connection information of the database, and assigns the real database (in the above example the real database is DB wow)  an alias db_1.

After that, if you need to load the table of DB wow, you can use db_1 to cite directly.

### Can data be loaded into the memory of Byzer engine when loading?
The answer is no. The engine will pull data from MySQL in batches for calculation. At the same time, only part of the data is in the engine memory.

### Can filter conditions be loaded when loading?
Yes, but not necessary. Users can directly put conditions in subsequent select statements. Where conditions in select statements will be pushed down to the storage for filtering, avoiding data transmission.

### What should we do when counting is very slow?
For example, users want to execute the following statements to check the number of data in the table below. If the table is relatively large, counting may be very slow and it may even cause some nodes in the Engine to unlink.

```sql
load jdbc.`db_1.tblname` as tblname;
select count(*) from tblname as newtbl;
```

The reason is that the engine needs to pull entire data (batch pull, not all loaded into memory), and then count and it is a single thread by default. Generally, it is relatively slow for database to do a full table scan, so counting without where conditions may be very slow , and even cann't run out.

If users just want to see the size of the table, it is recommended to use the directQuery mode. DirectQuery will send the query directly to the database for execution, and then return the calculation result to the engine, so it is very fast. The specific operation method is as follows:

```sql
load jdbc.`db_1.tblname` where directQuery='''
    select count(*) from tblname
''' as newtbl;
```

### If you add where conditions to select statements, the count speed is also very slow. (Sometimes even the engine does not work.)
Although you have added where conditions, the filtering effect may not be good, and the engine still needs to pull a large amount of data for calculation. The engine is single-threaded by default. We can configure multi-thread to pull data from the database, which can avoid single-thread's death.

The core parameters are as follows:

1. partitionColumn: which column to partition by
2. lowerBound and upperBound: the minimum and maximum value of the partition field which can be obtained by using directQuery
3. numPartitions: number of partitions. Generally, 8 threads are more suitable. The type of partition field should be the number, and it is recommended to use an auto-incrementing id field.

### If multi-threaded pulling is still slow, is there a way to speed it up further?
You can save the data to delta/hive by using the above methods and use it later. This allows you to sync once and use it multiple times. If you can't accept the delay, you can use Byzer to synchronize MySQL to Delta in real time. Please refer to [MySQL Binlog synchronization](/byzer-lang/zh-cn/datahouse/mysql_binlog.md) for more information.

### Are there any articles about the concept of loading JDBC data?
You can refer to [Depth analysis of Byzer loading JDBC data source](https://mp.weixin.qq.com/s/zaz8sRdIkQEUn65FPQfIQg) for more information.

### Concluding remarks
Whether it is JDBC data sources or traditional data warehouse data sources such as Hive, Byzer will provide indexing services for acceleration in the future, so stay tuned.

