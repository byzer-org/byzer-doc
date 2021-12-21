
## 接口权限控制

| 参数 | 说明 | 示例值 |
|----|----|-----|
|  spark.mlsql.auth.access_token  |  如果设置了，那么会开启 token 验证，任何访问引擎的接口都需要带上这个 token 才会被授权  | 默认不开启    |
|  spark.mlsql.auth.custom  | 设置接口访问授权的自定义实现类 |  默认无   |

用户可以将实现 `{def auth(params: Map[String, String]): (Boolean, String)` 的类使用 `--jars` 带上，然后通过 `--conf spark.mlsql.auth.custom= YOUR CLASS NAME` 来设置自定义的接口权限访问。

## 二层通讯参数

Byzer-lang 会在 Spark 之上构建一个二层通讯，方便 driver 直接控制 executor.

| 参数 | 说明 | 示例值 |
|----|----|-----|
|  streaming.ps.cluster.enable  |  是否开启二层通讯  |  默认为 true   |
|  spark.ps.cluster.driver.port  |  二层通讯 driver 端口 |  默认为 7777   |
|  streaming.ps.ask.timeout |  通讯超时 |  默认为 3600 秒   |
|  streaming.ps.network.timeout |  通讯超时 |  默认为 28800 秒   |

## Hive支持参数

| 参数 | 说明 | 示例值 |
|----|----|-----|
| streaming.enableHiveSupport  |  是否开启 hive 支持  |  默认为 false   |
|  streaming.hive.javax.jdo.option.ConnectionURL  | 用来配置 hive.javax.jdo.option.ConnectionURL|  默认为空   |

## 自定义UDF jar包注册

如果我们将自己的 UDF 打包进 Jar 包里，我们需要在启动的时候告诉系统对应的 UDF 类名称。
UDF 的编写需要符合 Byzer-Lang 的规范。我们推荐直接在 Console 里动态编写 UDF/UDAF。

| 参数 | 说明               | 示例值 |
|----|------------------|-----|
| streaming.udf.clzznames  | 支持多个 class, 用逗号分隔 |     |

## 离线插件安装

确保插件的jar包都是用`--jars`带上。并且目前只支持 app 插件。

| 参数 | 说明 | 示例值 |
|----|----|-----|
| streaming.plugin.clzznames  |  支持多个 class，用逗号分隔  |     |


## Session设置

Byzer-lang 支持用户级别 Session, 请求级别 Session。每个 Session 相当于构建了一个沙盒，避免不同请求之间发生冲突。默认是用户级别 Session，如果希望使用请求级别 Session ，需要在请求上带上 `sessionPerRequest` 参数。对此参看[Rest接口详解](../developer/api/run_script_api.md)。


| 参数 | 说明 | 示例值 |
|----|----|-----|
| spark.mlsql.session.idle.timeout  |  session 一直不使用的超时时间  |  30 分钟   |
| spark.mlsql.session.check.interval  |  session 超时检查周期  |  5 分钟   |

## 分布式日志收集

Byzer-lang 支持将部分任务的日志发送到Driver。

| 参数 | 说明 | 示例值 |
|----|----|-----|
| streaming.executor.log.in.driver  |  是否在 driver 启动日志服务  | 默认为 true|

## 权限校验

| 参数 | 说明 | 示例值 |
|----|----|-----|
| spark.mlsql.enable.runtime.directQuery.auth  |  开启 directQuery 语句运行时权限校验  | 默认为 false|
| spark.mlsql.enable.runtime.select.auth  |  开启 select 语句运行时权限校验  | 默认为 false|
| spark.mlsql.enable.datasource.rewrite  |  开启数据源加载时动态删除非授权列  | 默认为 false|
| spark.mlsql.datasource.rewrite.implClass  |  设置自定义数据源列控制的实现类 | &nbsp;|
