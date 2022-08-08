# 写入 Hive

将表保存至 Hive：

```sql
save overwrite table1 as hive.`db.table1`;
```

如果需要分区，则使用

```sql
save overwrite table1 as hive.`db.table1` partitionBy col1;
```