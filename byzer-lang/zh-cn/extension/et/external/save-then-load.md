# 保存到增量表中再次加载

[save then load](https://github.com/byzer-org/byzer-extension/tree/master/save-then-load)  插件会将表保存到增量表中，并再次加载。

## 如何安装

在 Web 控制台中执行以下命令：

```sql
!plugin et add - "save-then-load-2.4" named saveThenLoad;
```

> 注意：示例中 byzer 的 spark 版本为 2.4 ，如果需要在 spark 3.X 的版本运行，请将安装的插件设置为 `save-then-load-3.0`


## 如何使用

```sql
!saveThenLoad tableName;
select * from tableName as output;
```