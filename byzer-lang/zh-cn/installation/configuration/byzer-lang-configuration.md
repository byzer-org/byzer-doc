# Byzer 引擎参数配置说明

### 配置文件

在下载安装 Byzer 引擎后，在 `$BYZER_HOME/conf` 目录下可以找到 Byzer 引擎的配置文件，目录结构如下：

```shell
|- byzer.properties                       # Byzer 引擎默认配置文件
|- byzer.properties.override              # Byzer 引擎用户可更改的配置文件，该配置文件的优先级要高于 byzer.properties 
|- byzer.properties.all-in-one.example    # Byzer all in one 产品包的配置示例
|- byzer.properties.server.example        # Byzer server 产品包的配置示例
```

1. `byzer.properties.override` 文件中配置的优先级要高于 `byzer.properties` 文件，即如果有相同的配置项， `byzer.properties.override` 文件中的值生效
2. 处于运维的考虑，建议用户使用 `byzer.properties.override` 来管理自己的配置


### 配置示例

#### byzer.properties.all-in-one.example

Byzer All In One 产品包中，`byzer.properties.override` 默认使用的是 `byzer.properties.all-in-one.example` 中的配置，配置内容如下，一般情况下用户无需更改 `byzer.properties.override` 即可直接启动 Byzer 引擎

```properties
# byzer.properties.all-in-one.example
# override example for all-in-one package

byzer.server.mode=all-in-one

streaming.master=local[*]
streaming.name=Byzer-lang-desktop
streaming.rest=true
streaming.thrift=false
streaming.platform=spark
streaming.spark.service=true
streaming.job.cancel=true
streaming.datalake.path=./data/
streaming.driver.port=9003
streaming.enableHiveSupport=false
streaming.plugin.clzznames=tech.mlsql.plugins.ds.MLSQLExcelApp,tech.mlsql.plugins.assert.app.MLSQLAssert,tech.mlsql.plugins.shell.app.MLSQLShell,tech.mlsql.plugins.ext.ets.app.MLSQLETApp,tech.mlsql.plugins.mllib.app.MLSQLMllib
```

#### byzer.properties.server.example

Byzer Server 产品包中，`byzer.properties.override` 默认使用的是 `byzer.properties.server.example` 中的配置，该配置无法直接启动，一般是需要进行手工配置修改的， 比如产品包中默认的配置信息如下

```properties
# byzer.properties.server.example
# override example for server package

byzer.server.mode=server

streaming.master=local[*]
streaming.name=Byzer-lang-server
streaming.rest=true
streaming.thrift=false
streaming.platform=spark
streaming.spark.service=true
streaming.driver.port=9003
streaming.enableHiveSupport=false
```

如果你需要将 Byzer 引擎运行在 Hadoop 集群上，那么你的 `byzer.properties.override` 应该加入一些 Spark 相关的配置并且配置 `$SPARK_HOME` 和 `$HADOOP_CONF_DIR` 环境变量，配置示例如下

```properties
# byzer.properties.override
spark.master=yarn
streaming.name=byzer-lang
streaming.rest=true
streaming.platform=spark
streaming.spark.service=true
streaming.plugin.clzznames=tech.mlsql.plugins.ds.MLSQLExcelApp,tech.mlsql.plugins.assert.app.MLSQLAssert,tech.mlsql.plugins.shell.app.MLSQLShell,tech.mlsql.plugins.ext.ets.app.MLSQLETApp,tech.mlsql.plugins.mllib.app.MLSQLMllib

# Spark config
spark.driver.memory=2g
spark.executor.memory=1g
spark.driver.cores=1
spark.executor.cores=1
spark.executor.instances=1
```


### 配置参数详解

#### 常用参数

| 参数 | 说明 | 示例值 |
|----|----|-----|
|  byzer.server.mode  |   区分产品包以及对应启动方式 | `server ` 和 `all-in-one`   |
|  streaming.master  |  等价于--master |  `local [*]` 和 `yarn`    |
|  streaming.name  |  应用名称  | 自定义即可    |
|  streaming.platform  |  平台 |  目前只有spark   |
|  streaming.rest  |  是否开启http接口 |   布尔值，需要设置为true  |
|  streaming.driver.port | HTTP服务端口 |  一般设置为9003  |
|  streaming.spark.service  | 执行完是否退出程序 |  true 不退出  false 退出  |
|  streaming.job.cancel | 支持运行超时设置 |  一般设置为true  |
|  streaming.datalake.path | 数据湖基目录 一般为 HDFS 上的目录 |  需要设置，否则很多功能会不可用，比如插件等 |

### Spark 参数

除了本章节提到的 Byzer 引擎的参数外， Spark 的参数都是可用的，一般情况需要调整的 Spark 参数是 Driver 和 Executor 的资源控制参数。

#### 接口权限控制

| 参数 | 说明 | 示例值 |
|----|----|-----|
|  spark.mlsql.auth.access_token  |  如果设置了，那么会开启 token 验证，任何访问引擎的接口都需要带上这个 token 才会被授权  | 默认不开启    |
|  spark.mlsql.auth.custom  | 设置接口访问授权的自定义实现类 |  默认无   |

用户可以将实现 `{def auth(params: Map[String, String]): (Boolean, String)` 的类使用 `--jars` 带上，然后通过 `--conf spark.mlsql.auth.custom= YOUR CLASS NAME` 来设置自定义的接口权限访问。

#### 二层通讯参数

Byzer-lang 会在 Spark 之上构建一个二层通讯，方便 driver 直接控制 executor.

| 参数 | 说明 | 示例值 |
|----|----|-----|
|  streaming.ps.cluster.enable  |  是否开启二层通讯  |  默认为 true   |
|  spark.ps.cluster.driver.port  |  二层通讯 driver 端口 |  默认为 7777   |
|  streaming.ps.ask.timeout |  通讯超时 |  默认为 3600 秒   |
|  streaming.ps.network.timeout |  通讯超时 |  默认为 28800 秒   |

#### Hive支持参数

| 参数 | 说明 | 示例值 |
|----|----|-----|
| streaming.enableHiveSupport  |  是否开启 hive 支持  |  默认为 false   |
|  streaming.hive.javax.jdo.option.ConnectionURL  | 用来配置 hive.javax.jdo.option.ConnectionURL|  默认为空   |

#### 自定义UDF jar包注册

如果我们将自己的 UDF 打包进 Jar 包里，我们需要在启动的时候告诉系统对应的 UDF 类名称。
UDF 的编写需要符合 Byzer-Lang 的规范。我们推荐直接在 Console 里动态编写 UDF/UDAF。

| 参数 | 说明               | 示例值 |
|----|------------------|-----|
| streaming.udf.clzznames  | 支持多个 class, 用逗号分隔 |     |

#### 离线插件安装

确保插件的jar包都是用`--jars`带上。并且目前只支持 app 插件。

| 参数 | 说明 | 示例值 |
|----|----|-----|
| streaming.plugin.clzznames  |  支持多个 class，用逗号分隔  |     |


#### Session设置

Byzer-lang 支持用户级别 Session, 请求级别 Session。每个 Session 相当于构建了一个沙盒，避免不同请求之间发生冲突。默认是用户级别 Session，如果希望使用请求级别 Session ，需要在请求上带上 `sessionPerRequest` 参数。对此参看[Rest接口详解](../developer/api/run_script_api.md)。


| 参数 | 说明 | 示例值 |
|----|----|-----|
| spark.mlsql.session.idle.timeout  |  session 一直不使用的超时时间  |  30 分钟   |
| spark.mlsql.session.check.interval  |  session 超时检查周期  |  5 分钟   |

#### 分布式日志收集

Byzer-lang 支持将部分任务的日志发送到Driver。

| 参数 | 说明 | 示例值 |
|----|----|-----|
| streaming.executor.log.in.driver  |  是否在 driver 启动日志服务  | 默认为 true|

#### 权限校验

| 参数 | 说明 | 示例值 |
|----|----|-----|
| spark.mlsql.enable.runtime.directQuery.auth  |  开启 directQuery 语句运行时权限校验  | 默认为 false|
| spark.mlsql.enable.runtime.select.auth  |  开启 select 语句运行时权限校验  | 默认为 false|
| spark.mlsql.enable.datasource.rewrite  |  开启数据源加载时动态删除非授权列  | 默认为 false|
| spark.mlsql.datasource.rewrite.implClass  |  设置自定义数据源列控制的实现类 | &nbsp;|
