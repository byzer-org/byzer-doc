# 安装与卸载

安装前请查看 [安装前置条件](/byzer-notebook/zh-cn/installation/prerequisites.md)

### 下载 Byzer Notebook

社区提供了三种下载渠道
- [Byzer 社区官方下载站点](https://download.byzer.org/byzer-notebook/)
- [Byzer Notebook Github Release](https://github.com/byzer-org/byzer-notebook/releases)
- [Docker Hub](https://hub.docker.com/r/byzer/byzer-notebook)

Byzer Notebook 产品包的命名遵从以下规约： `Byzer-Notebook-<byzer_notebook_version>.tar.gz`    

`<byzer_notebook_version>` 对应着 Byzer Notebook 的两种版本：
- nightly build 版本，是基于最新开发分支每天自动构建的产品版本，版本号为 `latest`
- 发布版本，已发布的经过测试的版本，版本号为三位，比如 `1.1.1` 

###　二进制包安装

如果您通过　Byzer 社区官方下载站点下载的 Byzer Notebook 二进制包，则使用如下方式进行安装

#### 解压缩

通过cd命令进入下载的 Byzer Notebook 的路径中。

解压：

```shell
tar -xvf Byzer-Notebook-<byzer_notebook_version>.tar.gz
```

解压后得到 `Byzer-Notebook-<byzer_notebook_version>` 文件夹，里面的文件如下：


```
Byzer-Notebook-<byzer_notebook_version>
  |-- bin                     # 包含 notebook.sh 等可执行脚本
  |-- conf                    # notebook 的配置文件
  |-- lib                     # notebook 产品 jar 包位置
  |-- logs                    # notebook 运行产生的日志路径
  |-- sample                  # notebook 自带的 sample 及 data
  |-- CHANGELOG.md            # change log 文件
  |-- VERSION                 # verion 文件
  |-- commit_SHA1             # 该产品包对应的后端的 commit 记录
  |-- commit_SHA1.frontend    # 该产品包对应的前端的 commit 记录
```

### 配置文件

找到 `conf` 目录下 `notebook.properties` 文件，您可参考下方配置项说明，更改或增加配置。

> **注意：** 一般情况下，您只需要进行修改和配置数据库以及引擎回调地址的几个参数


#### 基本配置项说明

| 配置项                               | 描述                                                                                                      |
|-----------------------------------|---------------------------------------------------------------------------------------------------------|
| notebook.port                     | Byzer Notebook服务所用的端口，默认：`9002`。                                                                        |
| notebook.session.timeout          | Session 超时时间，默认：`12h`（12小时）。                                                                            |
| notebook.security.key             | 加密密钥（HexString），用于用户密码等敏感信息的加密，**不推荐更改此项配置**。                                                           |
| notebook.database.type            | 元数据库类型，默认：`mysql`，**暂只支持 MySQL**。                                                                       |
| notebook.database.ip              | 元数据库地址，默认：`localhost`。                                                                                  |
| notebook.database.port            | 元数据库端口，默认：`3306`。                                                                                       |
| notebook.database.name            | 元数据库 schema，默认：`notebook`。                                                                              |
| notebook.database.username        | 元数据库连接账号，默认：`root`。                                                                                     |
| notebook.database.password        | 元数据库连接账号的密码，默认：`root`。                                                                                  |
| notebook.execution.timeout        | 运行 Byzer 脚本的超时时间（秒），默认：`2880`。                                                                          |
| notebook.url                      | Byzer Notebook 服务地址，作用是给 Byzer 引擎回调，默认：`http://localhost:9002`。**您在配置此项时，应当保障此地址能被 Byzer 引擎访问。**        |                                                                                                         |
| notebook.mlsql.engine-url         | 默认 Byzer 引擎 API 地址，默认：`http://localhost:9003`，使用时可在设置页面切换引擎。                                            |
| notebook.mlsql.engine-backup-url  | 备用 Byzer 引擎 API 地址 ，默认：`http://localhost:9004`，使用时可在设置页面切换引擎。                                           |
| notebook.mlsql.auth-client        | Byzer 引擎鉴权插件，默认：`streaming.dsl.auth.client.DefaultConsoleClient`。您可自己开发鉴权插件配置在 Byzer 引擎端，而后将此项配置改为您的插件。 |
| notebook.user.home                | Byzer 引擎端用户文件目录，默认：`/mlsql`。 **您可以进行自定义路径，请确保启动 Byzer Notebook 的帐号对该路径有读写权限** |
| notebook.job.output-size          | `Cell` 执行结果显示的记录条数限制，默认：`1000`                                                                          |
| notebook.job.history.archive-time | 定时归档任务记录，将 N 天前的记录移入归档，默认：`7`（自动归档 7 天前的任务记录）                                                           |
| notebook.job.history.max-size     | 定时清理已归档的任务记录时，最多保留 N 条记录，默认：`2000000`                                                                   |
| notebook.job.history.max-time     | 定时清理已归档的任务记录时，删除 N 天前的记录，默认：`30`（自动删除 30 天前的任务记录）                                                       |

#### 高级配置
1. 如果您需要集成 Dolphin 调度系统来使用，请参考章节 [接入调度系统](/byzer-notebook/zh-cn/schedule/setup.md)
2. 如果您需要将 Notebook 和其他的系统进行集成，需要启用 Redis 来进行用户 Session 的同步，可以修改一下参数

| 配置项 | 描述  |
|------|-----|
| notebook.env.redis-enable   | 是否启用 Redis， 默认值为 `false`  |
| notebook.redis.host  | Redis 的 host，默认值 `localhost`   |
| notebook.redis.port | Redis 端口，默认值 `6379`  |
| notebook.redis.password  | Redis 库的密码， 默认值 `redis_pwd`   |
| notebook.redis.database  | Redis 库，默认值 `0` |

### 启动

> 需要首先启动 Byzer-lang, 它的部署安装请翻看 [Byzer-lang 部署指引](/byzer-lang/zh-cn/installation/README.md)

进入 `Byzer-Notebook-<byzer_notebook_version>` 目录，执行：

```shell
$ cd /path/to/Byzer-Notebook-<byzer_notebook_version>
$ ./bin/notebook.sh start
```

执行后，如何您看到下述显示，说明 Notebook 已经启动成功：
```shell
$ ./bin/notebook.sh start
Starting Byzer Notebook...

Byzer Notebook is checking installation environment, log is at /home/zhengshuai/Downloads/ByzerTest/Byzer-Notebook-latest/logs/check-env.out

Checking Java Version
...................................................[PASS]
Checking MySQL Availability & Version
...................................................[PASS]
Checking Byzer engine
...................................................[PASS]
Checking Ports Availability
...................................................[PASS]

Checking environment finished successfully. To check again, run 'bin/check-env.sh' manually.


NOTEBOOK_HOME is:/home/zhengshuai/Downloads/ByzerTest/Byzer-Notebook-latest
NOTEBOOK_CONFIG_FILE is:/home/zhengshuai/Downloads/ByzerTest/Byzer-Notebook-latest/conf/notebook.properties
NOTEBOOK_LOG_FOLDER is：/home/zhengshuai/Downloads/ByzerTest/Byzer-Notebook-latest/logs .

2022-04-27 22:19:09 Start Byzer Notebook...

Byzer Notebook is starting. It may take a while. For status, please visit http://192.168.49.1:9002.

You may also check status via: PID:358716, or Log: /home/zhengshuai/Downloads/ByzerTest/Byzer-Notebook-latest/logs/notebook.log.

```

启动程序会对环境做检查，包括 JAVA，MySQL，Byzer Engine 以及对应的端口占用：
- 如果环境检查成功，则会真正的执行启动命令，最终会在终端中显示可访问的 Notebook 地址，并会在 `$NOTEBOOK/bin` 目录下生成一个 `check-env-bypass` 文件，这样在下次启动时，会跳过除了端口占用之外的所有检查项
- 如果环境检查不通过，则启动失败


### 日志信息
Notebook 运行日志将会生成在 `$NOTEBOOK_HOME/logs` 文件夹内，结构如下：

```shell
$NOTEBOOK_HOME/logs
  |- notebook.log               # Notebook 主日志文件
  |- notebook.out               # Notebook 产生的标准日志输出，包含 Springboot 等日志信息
  |- shell.stderr               # 命令行执行输出的所有日志信息
  |- shell.stdout               # 命令行执行输出的标准日志输出
  |- check-env.error            # 执行 `check-env.sh` 产生的错误日志输出
  |- check-env.out              # 执行 `check-env.sh` 产生的标准日志输出
  |- notebook_access.log        # REST 接口的访问日志
  |- security.log               # 操作执行记录日志，包含执行操作，执行人，以及时间等信息
```



### 停止

进入 `Byzer-Notebook-<byzer_notebook_version>` 目录，执行：

```shell 
$ ./bin/notebook.sh stop 
```
当您看到如下日志输出时，说明 Notebook 进程已停止启动

```shell
$ ./bin/notebook.sh stop 
2022-04-27 22:39:18 Stopping Byzer Notebook...
This user don't have permission to run crontab.
2022-04-27 22:39:21 Byzer Notebook: 368419 has been Stopped
```

### 重启

如果您需要重启 Notebook 应用，比如修改了配置等，您可以通过执行如下命令进行 Notebook 进程的重启操作


```shell 
$ ./bin/notebook.sh restart 
```

### 卸载

请在卸载之前，确保服务已停止。

可直接删除对应的文件夹卸载 Byzer Notebook：

```bash
rm -rf Byzer-Notebook-<byzer_notebook_version>
```

### Docker 镜像启动

#### 1. 拉取 Byzer Notebook 镜像

```shell
docker pull byzer/byzer-notebook:版本号
```

> `版本号` 请参考 Byzer Notebook 的 Release Tags：https://github.com/byzer-org/byzer-notebook/tags
>
> 获取方式：e.g. tag 为 v1.0.1，则使用版本号 1.0.1，执行 `docker pull byzer/byzer-notebook:1.0.1`

如果需要体验最新版本 Byzer Notebook 的镜像：

```shell
docker pull byzer/byzer-notebook:latest
```

> `latest` 为 Nightly Build 版本，该版本为非稳定版本，包含最新研发但尚未 release 的特性。

#### 2. 启动

> 启动时可通过挂载目录 `-v /path/to/conf_dir:/home/deploy/byzer-notebook/conf  ` 使用自定义的配置文件，详见上文**配置文件**小节。

```shell
docker run -itd -v /path/to/conf_dir:/home/deploy/byzer-notebook/conf -p 9002:9002 --name=byzer-notebook byzer/byzer-notebook:版本号
```

