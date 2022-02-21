# MongoDB

MongoDB 是一个应用很广泛的存储系统。Byzer 也支持将其中的某个索引加载为表。

注意，MongoDB 的包并没有包含在 Byzer 默认发行包里，所以你需要通过 `--jars` 添加相关的依赖才能使用。

### 加载数据

**例子：**

```sql
> SET data='''{"jack":"cool"}''';

> LOAD jsonStr.`data` as data1;

> SAVE overwrite data1 AS mongo.`twitter/cool` WHERE
    partitioner="MongoPaginateBySizePartitioner"
    and uri="mongodb://127.0.0.1:27017/twitter";

> LOAD mongo.`twitter/cool` WHERE
    partitioner="MongoPaginateBySizePartitioner"
    and uri="mongodb://127.0.0.1:27017/twitter"
    AS table1;
> SELECT * FROM table1 AS output1;

> CONNECT mongo WHERE
    partitioner="MongoPaginateBySizePartitioner"
    and uri="mongodb://127.0.0.1:27017/twitter" 
    AS mongo_instance;

> LOAD mongo.`mongo_instance/cool` AS table1;

> SELECT * FROM table1 AS output2;

> LOAD mongo.`cool` WHERE
    partitioner="MongoPaginateBySizePartitioner"
    and uri="mongodb://127.0.0.1:27017/twitter"
    AS table1;
> SELECT * FROM table1 AS output3;
```

> 在MongoDB里，数据连接引用和表之间的分隔符不是`.`,而是`/`。

