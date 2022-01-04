# /run/script 接口

该接口用来执行 Byzer-lang 语句。

Method: POST GET

Content-Type: application/x-www-form-urlencoded

## 参数列表

| 参数 | 说明                                                                                                                       | 示例值 |
|----|--------------------------------------------------------------------------------------------------------------------------|-----|
| sql  | 需要执行的 Byzer-lang 内容                                                                                                      |     |
| owner  | 当前发起请求的租户                                                                                                                |     |
| jobType  | 任务类型 script/stream/sql  默认script                                                                                         |     |
| executeMode  | 如果是执行 Byzer-lang 则为 query, 如果是为了解析 Byzer-lang 则为 analyze。很多插件会提供对应的 executeMode 从而使得用户可以通过 HTTP 接口访问插件功能                 |     |
| jobName  | 任务名称，一般用 uuid 或者脚本 id ,最好能带上一些信息，方便更好的查看任务                                                                               |     |
| timeout  | 任务执行的超时时间                                                                                                                | 单位毫秒    |
| silence  | 最后一条SQL是否执行                                                                                                              | 默认为 false|
| sessionPerUser  | 按用户创建 sesison                                                                                                            | 默认为 true|
| sessionPerRequest  | 按请求创建 sesison                                                                                                            | 默认为 false,一般如果是调度请求，务必要将这个值设置为true|
| async  | 请求是不是异步执行                                                                                                                | 默认为 false|
| callback  | 如果是异步执行，需要设置回调URL                                                                                                        | |
| skipInclude  | 禁止使用 include 语法                                                                                                          | 默认false |
| skipAuth  | 禁止权限验证                                                                                                                   | 默认true  |
| skipGrammarValidate  | 跳过语法验证                                                                                                                   | 默认true  |
| includeSchema  | 返回的结果是否包含单独的 schema 信息                                                                                                   | 默认false  |
| fetchType  | take/collect, take 在查看表数据的时候非常快                                                                                          | 默认collect  |
| defaultPathPrefix  | 所有用户主目录的基础目录                                                                                                             |   |
| `context.__default__include_fetch_url__`  | Byzer-lang Engine 获取 include 脚本的地址                                                                                       | |
| `context.__default__fileserver_url__` | 下载文件服务器地址，一般默认也是 Notebook 地址                                                                                             |   |
| `context.__default__fileserver_upload_url__` | 上传文件服务器地址，一般默认也是 Notebook 地址                                                                                             |   |
| `context.__auth_client__` | 权限认证客户端的类                                                                                                                |  默认是streaming.dsl.auth.meta.client.MLSQLConsoleClient |
| `context.__auth_server_url__` | 数据访问验证服务器地址                                                                                                              |   |
| `context.__auth_secret__` | Byzer-lang engine 回访请求服务器的密钥。比如 Notebook 调用了 Byzer-lang engine，需要传递这个参数， 然后 Byzer-lang engine 要回调 Notebook , 那么需要将这个参数带回 |   |


## 例子
调用本机 API 例子
```shell
curl --location --request POST 'http://localhost:9003/run/script' \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'sql=select 1 as id as output;' \
--data-urlencode 'owner=admin' \
--data-urlencode 'jobName=91f8e37d-cfc7-4167-b396-7f33c14bc7da'
```