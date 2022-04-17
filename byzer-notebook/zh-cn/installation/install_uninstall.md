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

<p align="center">
<img src="/byzer-notebook/zh-cn/installation/image/image-files.png" title="image-ray-started"/>
</p>

### 配置文件

找到 `conf` 目录下 `notebook.properties` 文件，您可参考下方配置项说明，更改或增加配置。

> **注意：**
> 1. 一般情况下，您只需要进行修改和配置数据库以及引擎回调地址的几个参数
> 2. 启动 Notebook 前，需要您手动在 MySQL 中手动创建 Database, 默认为`notebook`

#### 配置项说明

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
| notebook.user.home                | Byzer 引擎端用户文件目录，默认：`/mlsql`。                                                                            |
| notebook.job.output-size          | `Cell` 执行结果显示的记录条数限制，默认：`1000`                                                                          |
| notebook.job.history.archive-time | 定时归档任务记录，将 N 天前的记录移入归档，默认：`7`（自动归档 7 天前的任务记录）                                                           |
| notebook.job.history.max-size     | 定时清理已归档的任务记录时，最多保留 N 条记录，默认：`2000000`                                                                   |
| notebook.job.history.max-time     | 定时清理已归档的任务记录时，删除 N 天前的记录，默认：`30`（自动删除 30 天前的任务记录）                                                       |

### 启动

> 需要首先启动 Byzer-lang, 它的部署安装请翻看 [Byzer-lang 部署指引](/byzer-lang/zh-cn/installation/README.md)

进入 `Byzer-Notebook-<byzer_notebook_version>` 目录，执行：

```bash
# nohup 启动
./startup.sh

# hang up 启动
./startup.sh hangup
```

您可查看 `logs/notebook.log`，看到下面日志说明服务成功启动。

<p align="center">
<img src="/byzer-notebook/zh-cn/installation/image/image-started.png" title="image-ray-started"/>
</p>

### 停止

进入 `Byzer-Notebook-<byzer_notebook_version>` 目录，执行：

```bash  
./shutdown.sh
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

> 该版本为非稳定版本，包含最新研发但尚未 release 的特性。

#### 2. 启动

> 启动时可通过挂载目录 `-v /path/to/conf_dir:/home/deploy/byzer-notebook/conf  ` 使用自定义的配置文件，详见上文**配置文件**小节。

```shell
docker run -itd -v /path/to/conf_dir:/home/deploy/byzer-notebook/conf -p 9002:9002 --name=byzer-notebook byzer/byzer-notebook:版本号
```

