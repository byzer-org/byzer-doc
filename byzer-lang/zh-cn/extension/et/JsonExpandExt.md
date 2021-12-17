# Json展开插件使用
数据处理中，JSON数据很常见的，例如埋点数据。Hive Spark均提供了JSON处理函数，
使用MLSQL 插件，可以方便地将一个JSON字段展开为多个字段。
下面以例子介绍其使用方式。
### 使用例子
- 查看帮助
```sql
load modelExample.`JsonExpandExt` AS output;
```
- 例子1：JSON没有嵌套
```sql
SELECT '{"name":"Michael"}' AS col_1
UNION ALL
SELECT '{"name":"Andy", "age":30}' AS col_1 AS table_1;

run table_1 as JsonExpandExt.`` where inputCol="col_1" AND samplingRatio = "1.0" as table_2;
```
结果如下

|name | age| 
|---|---|
|Michael | |
|Andy |30|

这里，inputCol表示JSON字段名称，这里是col_1。samplingRatio 指系统采样分析JSON结构的采样率，为大于0小于1
的小数。

- 例子2：嵌套的JSON
```sql
SELECT '{"name":"Michael", "address":{"city":"hangzhou", "district":"xihu"} } ' AS col_1 AS table_1;
run table_1 as JsonExpandExt.`` where inputCol="col_1" AND samplingRatio = "1.0" as table_2;
run table_2 AS JsonExpandExt.`` WHERE inputCol="address" AS table_3;
```
结果如下

|name|city|district|
|---|---|---|
|Michael|hangzhou|xihu|
本例子的city 嵌套在第二层，因而需要执行两次run 语句。

### 功能快速体验
我们提供了[Docker镜像](https://github.com/allwefantasy/mlsql-build#running-sandbox)，供用户快速体验。
启动容器后，浏览器输入 http://127.0.0.1:9003, 运行上述代码。

### 意见反馈
若有任何问题，请至 [mlsql github主页](https://github.com/allwefantasy/mlsql)，首页有二维码，扫码加入用户群或者提交Issue。
