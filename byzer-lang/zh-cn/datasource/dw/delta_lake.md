# Delta Lake 数据源

Delta 本质就是 HDFS 上一个目录。我们会分如下几个部分介绍 Delta 的使用：


###  基本使用

```sql
set rawText='''
{"id":1,"content":"MLSQL 是一个好的语言","label":0.0},
{"id":2,"content":"Spark 是一个好的语言","label":1.0}
{"id":3,"content":"MLSQL 语言","label":0.0}
{"id":4,"content":"MLSQL 是一个好的语言","label":0.0}
{"id":5,"content":"MLSQL 是一个好的语言","label":1.0}
{"id":6,"content":"MLSQL 是一个好的语言","label":0.0}
{"id":7,"content":"MLSQL 是一个好的语言","label":0.0}
{"id":8,"content":"MLSQL 是一个好的语言","label":1.0}
{"id":9,"content":"Spark 好的语言","label":0.0}
{"id":10,"content":"MLSQL 是一个好的语言","label":0.0}
''';

load jsonStr.`rawText` as orginal_text_corpus;

save append orginal_text_corpus as delta.`test_demo.table1`;
```

执行上面的语句，我们就能成功的将相关数据写入 Delta 数据湖了。

加载的方式如下：

```sql
load delta.`test_demo.table1` as output;
```

### 按数据库表模式使用

很多用户并不希望使用路径，他们希望能够像使用 Hive 那样使用数据湖。Byzer-lang 对此也提供了支持。在 `$BYZER_HOME/conf/byzer.properties.override` 中，加上参数

```
streaming.datalake.path=/tmp/datahouse
```

> 默认情况，/tmp/datahouse 是本地目录。若 $SPARK_HOME/conf 包含HDFS配置文件，/tmp/datahouse 指 HDFS 目录；同样的方式也可支持 OSS 等对象存储。
>
> 请先创建目录 /tmp/datahouse.

系统便会按数据湖模式运行。此时用户不能自己写路径了，而是需要按db.table的模式使用。

保存数据湖表

```sql
select 1 AS id, 'abc' AS address
UNION ALL
SELECT 2 AS id, 'def' AS address
AS table_1;

save overwrite table_1 as delta.`default.table_1` partitionBy id;
```

加载数据湖表：

```sql
load delta.`default.table_1` as output;
```

你可以使用下列命令查看所有的数据库和表：

```sql
!delta show tables;
```

### 同时加载多版本数据为一个表

Delta 支持多版本，我们也可以一次性加载一个范围内的版本，比如下面的例子，我们说，将[12-14) 的版本的数据按
一个表的方式加载。接着用户可以比如可以按 id 做 group by，在一行得到多个版本的数据。

```sql
set a="b"; 

load delta.`/tmp/delta/rate-3-table` where 
startingVersion="12"
and endingVersion="14"
as table1;

select __delta_version__, collect_list(key), from table1 group by __delta_version__,key 
as table2;
```



### 7. 查看表的状态

```sql
!delta info scheduler.time_jobs;
```

