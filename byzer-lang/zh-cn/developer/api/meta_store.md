##  Byzer 元信息存储

支持插件后，Byzer 需要存储插件的信息。同时一些内置的插件也需要有一些状态存储，比如 scheduler service。  
目前 Byzer 提供了两种持久化存储的支持：

1. Delta Lake
2. MySQL

默认是delta lake. 开启方式为：

```
-streaming.datalake.path [HDFS路径]
```

> 在 yarn 下部署，暂时推荐 yarn-client 模式，需要保证提交 Byzer 任务的用户，在`start-default.sh`同级目录下，有创建目录的权限，或者提前创建好`__mlsql__`目录，并给予对应权限

也可以替换成 MySQL，开启方式为（无需关闭 Delta Lake）：

```
-streaming.metastore.db.type  "mysql",
-streaming.metastore.db.name  "app_runtime_full",
-streaming.metastore.db.config.path "./__mlsql__/db.yml"
```

你需要创建一个数据库，然后将 Byzer 项目根目录下的 db.sql 导入进去。db.yml 的示例配置如下：

```
app_runtime_full:
  host: 127.0.0.1
  port: 3306
  database: app_runtime_full
  username: xxxxx
  password: xxxx
  initialSize: 8
  disable: false
  removeAbandoned: true
  testWhileIdle: true
  removeAbandonedTimeout: 30
  maxWait: 100
  filters: stat,log4j
```
