# Frequent issues when loading JDBC data, like MySQL, Oracle
Byzer supports the JDBC data source (such as MySQL and Oracle) with Load syntax. Common usage methods are as follows. For more information, see chapter [JDBC](/byzer-lang/en-us/datasource/jdbc.md).

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

Among them, **connect** doesn't mean to connect to a database. This statement will not trigger the real connection action. It only records the connection information of the database, and assigns an alias (db_1) to the real database (database wow in this example)  .

After that, if you need to load the table from database wow, you can use db_1directly.

### Can data be loaded into the memory of Byzer engine?
No. The engine will pull data from MySQL in batches for calculation. At the same time, only part of the data will be loaded into the engine memory.

### Will filter conditions also be loaded when loading?
Yes, but not necessarily. You can directly write the filters in the `where` condition of the `select` statement, which will be pushed down to the cloud storage for filtering, to reduce the data transfer expenditure. 

### What should we do when counting is very slow?
For example, users want to execute the following statements to check the number of data in a table. If the table is relatively large, counting may be very slow and some Engine nodes may stop responding.

```sql
load jdbc.`db_1.tblname` as tblname;
select count(*) from tblname as newtbl;
```

The reason is that the engine needs to pull the entire data (in batch mode, not that all data will be loaded into the memory), and then start the counting.  And this is a single thread process by default. Generally speaking, it is relatively slow when the database need to do a full table scan, so counting when there is no `where` condition will be very slow , and even may not work at all.

If a user only wants to check the size of the table, it is recommended to use the `directQuery` mode. `DirectQuery` will send the query directly to the database for execution, and then return the calculation result to the Engine, so it is very fast. The specific operation method is as follows:

```sql
load jdbc.`db_1.tblname` where directQuery='''
    select count(*) from tblname
''' as newtbl;
```

### Even if I add `where` condition to the `select` statement, the count speed is still very slow, the Engine may even stop responding.
Although you have added the  `where` condition, the filtering effect may not be good, as the Engine still needs to pull a large amount of data for calculation. The Engine is single-threaded by default. To solve this, we can configure a multi-thread method to pull data from the database, avoiding single thread's deadlocks.

The core parameters are as follows:

1. `partitionColumn`: partition by which column
2. `lowerBound` and `upperBound`: minimum and maximum value of the partition field (can be obtained by using `directQuery`)
3. `numPartitions`: number of partitions. Generally, 8 threads are recommended. The type of partition field should be the number, and it is recommended to use an auto-incrementing id field.

### If multi-threaded pulling is still slow, is there a way to speed up?
You can save the data to delta/hive before pulling the data. Then you only need to  sync once. If you can't be tolerant the delay, you can use Byzer to synchronize MySQL to Delta in real-time. Please refer to [MySQL Binlog synchronization](/byzer-lang/zh-cn/datahouse/mysql_binlog.md) for more information.

### Are there any articles about the principles?
You can refer to [Depth analysis of Byzer loading JDBC data source](https://mp.weixin.qq.com/s/zaz8sRdIkQEUn65FPQfIQg) for more information.

### Conclusion
Whether it is JDBC data sources or traditional data warehouse data sources such as Hive, Byzer will provide unified indexing services to accelerate, so stay tuned.

