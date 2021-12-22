# Hive 数据源的读写
### 加载 Hive 表

<img style="zoom: 70%;" src="/byzer-notebook/zh-cn/datasource/images/hive-load.png">

### 在将表保存至 Hive 数据源

##### !提示: hive 和 spark 需要对应否则会出现保存失败的情况

解决方案: 在 save 之前执行 `set spark.sql.legacy.parquet.int96RebaseModeInWrite=CORRECTED  where type="conf";`

<img style="zoom: 70%;" src="/byzer-notebook/zh-cn/datasource/images/hive-save.png">



