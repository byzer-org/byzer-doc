# 如何使用 Byzer-lang 流式更新 MySQL 

很多场景会要求流式数据写入 MySQL, 而且通常都是 upsert 语义，也就是根据特定字段组合，
如果存在了则更新， 如果不存在则插入。Byzer-lang 在批处理层面，你只要配置一个 idCol 字段就可以实现 upsert 语义。
那么在流式计算里呢？

同样也是很简单的。 下面的例子来源于[用户讨论](https://github.com/allwefantasy/streamingpro/issues/919).

## 场景

有一个 patient 的主题 ( Kafka topic )，里面包含了
* name string
* age integer
* addr string (means the province the patient from)
* arriveTime long (timestamp in milliseconds)

我们要求根据 addr, arriveTime 作为unique key，如果存在更新否则 insert, 并且把数据存储在 MySQL 里。

## 流程

我们可以通过 load 语法把 Kafka 的 topic 加载成一张表：

```sql
set streamName="test_patient_count_update";

load kafka.`patient` options
`kafka.bootstrap.servers`="localhost:9092"
and `valueFormat`="json"
and `valueSchema`="st(field(name,string),field(age,integer),field(addr,string),field(arriveTime,string))"
as patientKafkaData;

```

因为 Kafka 里的数据是 JSON 格式的，我希望直接展开成 JSON 表，所以配置了 valueFormat 和 valueSchema ， 更多细节参考前面的章节。

接着连接 MySQL 数据库：

```sql
-- 更新用户名和密码
connect jdbc where
url="jdbc:mysql://localhost:3306/notebook?characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&useSSL=false"
and driver="com.mysql.jdbc.Driver"
and user="XXX"
and password="XXXXX"
as mydb;

```

第一步我们考虑使用存储过程（以及相关的表）

```
set procStr='''
CREATE DEFINER=`app`@`%` PROCEDURE `test_proc`(in `dt` date,in `addr` VARCHAR(100),in `num` BIGINT)
begin 
	DECLARE cnt bigint;
	select p.num into cnt from patientUpdate p where p.dt=`dt` and p.addr=`addr`;
	if ISNULL(CNT) then 
		INSERT into patientUpdate(dt,addr,num) values(`dt`,`addr`,`num`);
	else 
		update patientUpdate p set p.num=`num` where p.dt=`dt` and p.addr=`addr`;
	end if;
end
''' ;

-- create table and procedure 创建 table 和存储过程
select 1 as a as FAKE_TABLE;
run FAKE_TABLE as JDBC.`mydb` where 
`driver-statement-0`="create table  if not exists patientUpdate(dt date,addr varchar(100),num BIGINT)"
and 
`driver-statement-1`="DROP PROCEDURE IF EXISTS test_proc;"
and
`driver-statement-2`="${procStr}"

```

接着对数据进行操作，获得需要写入到数据库的表结构：

```
select name,addr,cast(from_unixtime(arriveTime/1000) as date) as dt from patientKafkaData as patient;

select dt,addr,count(*) as num from patient
group by dt,addr
as groupTable;
```

最后，调用save语法写入：

```sql
save append groupTable
as streamJDBC.`mydb.patient` 
options mode="update"
-- call procedure 调用存储过程
and `statement-0`="call test_proc(?,?,?)"
and duration="5"
and checkpointLocation="/streamingpro-test/kafka/patient/mysql/update";
```

存储过程是个技巧。其实还有更好的办法：

```
select dt,addr,num, dt as dt1, addr as addr2 from groupTable as outputTable;

save append outputTable  
as streamJDBC.`mydb.patient` 
options mode="update"
and `statement-0`="insert into patientUpdate(dt,addr,num) value(?,?,?) ON DUPLICATE KEY UPDATE dt=?,addr=?,num=?;"
and duration="5"
and checkpointLocation="/streamingpro-test/kafka/patient/mysql/update";
```

通过`ON DUPLICATE KEY UPDATE`实现相关功能。 指的注意的是，statement-0 里是原生的sql语句，通过`?`占位符来设置参数，
我们会把待写入的表字段按顺序配置给对应的 SQL 语句。
