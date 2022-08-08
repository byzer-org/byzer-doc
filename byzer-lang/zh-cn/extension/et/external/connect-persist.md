# Connect语句持久化

[connect-persist](https://github.com/byzer-org/byzer-extension/tree/master/connect-persist) 用于持久化connect语句。当系统重启后，无需再执行connect语句。

### 如何安装

> 如果Byzer Meta Store 采用了MySQL存储，那么你需要使用 https://github.com/byzer-org/byzer-extension/blob/master/connect-persist/db.sql
> 中的表创建到该MySQL存储中。

完成如上操作之后，安装插件：

```
!plugin app add - 'connect-persist-app-3.0';
```

> 注意：示例中 byzer 的 spark 版本为 3.0 ，如果需要在 spark 2.4 的版本运行，请将安装的插件设置为 `connect-persist-app-2.4`


### 如何使用

```sql
!connectPersist;
```

所有执行过的connect语句都会被保留下来。当系统重启后，会重新执行。 接下来我们看一个具体的例子。

```sql
-- 连接客户端byzer的数据库notebook，取别名为db1
connect jdbc where
url="jdbc:mysql://127.0.0.1:3306/notebook?useUnicode=true&zeroDateTimeBehavior=convertToNull&characterEncoding=UTF-8&zeroDateTimeBehavior=convertToNull&tinyInt1isBit=false&autoReconnect=true&failOverReadOnly=false"
and driver="com.mysql.jdbc.Driver"
and user="root"
and password="root"
as db1;

持久化该connect连接
!connectPersist;
```

重启byzer-lang引擎，我们可以在后台日志中看到持久化的连接被打印出来：

```
21/12/15 22:24:37  INFO PluginHook: Register App Plugin connect-persist-app-3.0 in tech.mlsql.plugins.app.ConnectPersistApp
21/12/15 22:24:38  INFO ConnectPersistApp: load connect statement format: jdbc db:db1
```

启动后执行下面语句：

```sql
load jdbc.`db1.mlsql_job` as newtable;

select * from newtable as output limit 1;
```

可以看到成功查询到了数据，db1连接已经被持久化。


| id   | name              | user | cell_list                                                    |
| ---- | ----------------- | ---- | ------------------------------------------------------------ |
| 27   | 03_Demo_Notebook2 | zepp | [ 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131 ] |
### 使用mysql存储元信息

前面我们提到，byzer Meta Store 可以采用MySQL存储，具体使用方式，请参考：[byzer元信息存储](/byzer-lang/zh-cn/developer/api/meta_store.md)

