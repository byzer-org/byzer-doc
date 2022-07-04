# 接入调度系统

目前版本的 Byzer Notebook 只支持接入 **1.3.9** 版本的 **DolphinScheduler** 系统，未来会增加对其他调度系统的支持。

### 接入 DolphinScheduler

在执行以下操作前，您需要安装 1.3.9 版本的 DolphinScheduler，请参考 [DolphinScheduler 1.3.9 安装配置指南](/byzer-notebook/zh-cn/schedule/install_dolphinscheduler.md)

> 注意：
>
> 1. 您需要确保 Byzer Notebook 所在环境与 DolphinScheduler 所在环境网络是联通的；
>2. 在启动 Byzer Notebook 服务前，确保 DolphinScheduler 服务正常运行。

#### 创建 Auth-Token

Byzer Notebook 通过调用 DolphinScheduler 的 API 接口进行调度的创建、管理，因此您需要在 DolphinScheduler 端为 Byzer Notebook 创建一个
auth-token。为此，建议您在 DolphinScheduler 系统中为 Byzer Notebook 单独创建一个运行账号，用该账号登录调度系统，点击 "安全中心"，再点击左侧的 "令牌管理"，点击 "令牌管理" 创建令牌。

<p align="center">
    <img src="/byzer-notebook/zh-cn/schedule/images/dolphin_token.png" alt="dolphin_token"  width="800"/>
</p>

#### 修改 Byzer Notebook 配置项

找到 `conf` 目录下 `notebook.properties` 文件，您可参考下方配置项说明，更改或增加配置。例如，在配置文件中新增以下几行记录，即可让 Byzer Notebook 服务接入其同主机的
DolphinScheduler：

```properties
notebook.scheduler.enable=true
notebook.scheduler.scheduler-name=DolphinScheduler
notebook.scheduler.scheduler-url=http://localhost:12345/dolphinscheduler
notebook.scheduler.auth-token=6bb923731815757b71e87920be033797
notebook.scheduler.callback-token=localNotebook-token-for-localDolphin
```

修改好配置项后，进入 `Byzer-Notebook-<byzer_notebook_version>` 目录，运行 `./shutdown.sh && ./startup.sh` 重启服务，即可在 Byzer Notebook
中使用调度功能。

##### 配置项说明：

| 配置项                               | 描述                                                                                                |
|-----------------------------------|---------------------------------------------------------------------------------------------------|
| notebook.scheduler.enable         | 调度功能开关，默认：`false`。                                                                                |
| notebook.scheduler.scheduler-name | 外接调度系统类型，目前只支持 `DolphinScheduler`。                                                                |
| notebook.scheduler.scheduler-url  | 外接调度系统 url。                                                                                       |
| notebook.scheduler.auth-token     | 外接调度系统提供的 auth-token，供 Byzer Notebook 调用其 API。                                                    |
| notebook.scheduler.callback-token | 外接调度系统执行任务时，回调 Byzer Notebook 用的鉴权验证 token。                                                       |
| notebook.scheduler.callback-url   | 当您开启了调度开关，此地址将被 DolphinScheduler 回调使用，**您需要确保此地址能被 DolphinScheduler 服务访问**，默认与 `notebook.url` 一致。 |

##### 以下为接入 DolphinScheduler 的可选配置项：

| 配置项                                  | 描述                                                                                                     |
|--------------------------------------|--------------------------------------------------------------------------------------------------------|
| notebook.scheduler.project-name      | 指定项目，Byzer Notebook 只会在此项目下创建调度任务，默认：`ByzerScheduler`。                                                 |
| notebook.scheduler.warning-type      | DolphinScheduler 中调度执行结束时，根据执行状态发送告警，包含成功或失败都发、成功发、失败发、任何状态都不发，可选：`ALL/SUCCESS/FAILURE/NONE`，默认：`ALL`。 |
| notebook.scheduler.warning-group-id  | DolphinScheduler 中的告警组 ID，默认：`1`。                                                                      |
| notebook.scheduler.failure-strategy  | 当某一个任务节点执行失败时，其他并行的任务节点需要执行的策略。可选：`CONTINUE/END`，默认：`END`，意为终止所有正在执行的任务，并终止整个流程。                       |
| notebook.scheduler.instance-priority | DolphinScheduler 中调度运行的优先级，可选：`HIGHEST/HIGH/MEDIUM/LOW/LOWEST`，默认：`MEDIUM`。                            |
| notebook.scheduler.worker            | 指定任务在哪个 Worker 机器组运行，默认：`default`，意为可在任一 Worker 上运行。                                                   |

> 以上是 DolphinScheduler 创建调度时的参数， 关于这些参数的详细解释请参考 [DolphinScheduler 使用手册](https://dolphinscheduler.apache.org/zh-cn/docs/1.3.9/user_doc/system-manual.html)

### 调度任务结束后通知机制

在 v1.2.1 版本中引入， Notebook 在做调度任务时，需要加入一个通知机制，可以当调度任务完成的时候，对执行的任务人员进行通知。

通知的方式暂时支持 IM 的 Webhook 机器人，比如飞书，企业微信，钉钉等。此类 IM 机器人是通过 HTTP URL 以及 Text 来定义消息接收方以及消息内容的。


用户可以通过配置文件 `$NOTEBOOK_HOME/conf/notebook.properties` 来定义接收方，接受消息的定制内容 text， 以及发送消息的等级。
参数设计如下：

```
# 填写 IM 机器人的 HTTP webhook url，默认为空
notebook.scheduler.notification.webhook-url= 
# 可选值 all（调度成功或失败都发送消息）, failed（只有调度失败发送消息），默认值为 failed
notebook.scheduler.notification.level=failed
# 消息通知 Header，用户可自定义,为字符串
notebook.scheduler.notification.message-header="Byzer Notebook Schedule Task Notification:"
```