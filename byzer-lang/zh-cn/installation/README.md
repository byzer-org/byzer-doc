# Byzer 引擎部署指引

Byzer 引擎为 Byzer-lang 提供了 Runtime 执行环境，有多种部署方式可以部署 Byzer 引擎，用户可以根据自己的情况和部署环境（开发，测试，生产）来选择不同的部署方式。

Byzer 引擎本质上来讲就是一个 Spark Service 实例， 分为 Driver 端和 Executor 端。得益于 Spark 的生态， Byzer 引擎部署从技术架构上来讲，可以同时支持 **Local 模式**， **Byzer on YARN 模式**，以及 **Byzer on K8S 模式**。


### 下载

请前往[Byzer 下载渠道](/byzer-lang/zh-cn/installation/download/site.md)章节，了解 Byzer 社区提供的官方下载渠道和方式

### 部署前提

#### 操作系统

Byzer 目前支持的系统有 Linux 以及 MacOS （Intel 芯片）， Windows 提供了部分支持。

- **生产环境**建议使用 CentOS 7.0 + 或 Ubuntu 16.04 +
- **开发测试环境**可根据自己的需求选择 Linux 个人发行版或 MacOS（Intel 芯片）
- Windows 仅做体验使用（Byzer VSCode Extension on Windows）

#### JDK

社区官方测试过的版本为 JDK 8

#### Spark

Byzer 引擎的运行时为 Spark，目前支持的版本分别有 `3.1.1` 以及 `2.4.3`，暂不支持其他版本的 Spark。

如果您使用的是 Hadoop 发行版，请在您的 Hadoop 中下载安装对应版本的 Spark，以及下载对应版本的 Byzer 引擎安装包

#### 文件系统

Byzer 引擎支持多种文件系统，包括本地文件系统 （`file://`），HDFS，对象存储以及 JuiceFS 等，您可以根据您的部署环境和需求，来选择对应的文件系统。

### Byzer 引擎说明
从 Byzer 社区建立开始，每一次发布都有对应的发布声明，用户可通过以下几个渠道进行发布声明的获取：
- 该手册文档的[发行说明章节](/byzer-lang/zh-cn/release-notes/version.md)
- Github Release 页面
    - [Byzer-lang Release](https://github.com/byzer-org/byzer-lang/releases)
    - [Byzer Notebook Release](https://github.com/byzer-org/byzer-notebook/releases)

#### Byzer 产品包分类
Byzer 社区提供了多种产品包来满足用户的不同使用场景。

|产品包类型| 部署说明 | 说明 | 适合场景 |
|--|--------|-----|----------|
|Binary Package| [部署 Byzer All In One 版本](/byzer-lang/zh-cn/installation/server/byzer-all-in-one-deployment.md)     |该版本内置了所有的依赖，包括 JDK，Spark Jars 等； 该版本同时内置了 Byzer CLI 的**命令行交互方式**和**服务化的 REST 交互方式**，<br>该产品包的默认配置 `all-in-one` 允许您直接将 Byzer 引擎运行在单机 Linux 系统或 MacOS上； 您也可以通过调整配置文件将其切换成 `server` 模式，来将该引擎跑在 Yarn 上或 K8S 上| 使用 `all-in-one` 的单机模式一般适合于快速体验 Byzer 引擎部署，本机开发环境的搭建，或者是测试环境的部署， 受限于单机的 CPU 核心数量和内存限制，一般情况下不适合生产环境；<br> 使用 `server` 模式等同于 Byzer Server 版本，可搭配 Hadoop 集群进行使用 |
|Binary Package| [部署 Byzer Server 版本](/byzer-lang/zh-cn/installation/server/byzer-all-in-one-deployment.md) | 该版本没有内置 JDK，也没有内置 Byzer CLI 可执行程序以及 Byzer Extensions，需要用户配置 JDK 以及 Spark 集群 <br> 默认情况下，该产品包使用 `server` 模式，只**支持服务化 REST 的交互方式**，您也可以前往官方下载站下载 Byzer CLI 以及 Byzer Extensions 来扩充产品能力| 一般适合于在生产环境进行部署，最常见的场景是搭配 Hadoop 集群进行使用 <br> |
|Image| [容器化部署](/byzer-lang/zh-cn/installation/containerized-deployment/containerized-deployment.md) | 提供了基于 Docker 的多种镜像，方便用户用于自动构建、部署服务，供快速体验 Byzer-lang 功能 | 一般适合于快速体验 Byzer 引擎部署，本机开发环境的搭建，或者是测试环境的部署， 受限于容器虚拟化，除了 K8S 部署模式外一般不适合生产环境  |
|Image| [K8S 环境部署](/byzer-lang/zh-cn/installation/k8s/k8s-deployment.md) | K8S 部署方案，本质上是使用了 Byzer 引擎的容器镜像，可以支持 minikube 或云上 K8S 服务|搭配基于云厂商的 K8S，适合做测试以及生产环境|
|VSCode Extension| [Byzer VSCode Extension](/byzer-lang/zh-cn/installation/vscode/byzer-vscode-extension-installation.md) | VisualStudio Code 插件，支持 Windows， Mac， Linux | 适合搭建本机开发环境和快速体验上手 |

> 1. 建议选择下载 Byzer All In One 版本， 该版本内置了 Byzer 官方的所有插件， 可以通过调整配置文件中的 `byzer.server.mode=all-in-one | server` 来进行单机或 Hadoop 集群部署模式的切换
> 2. 如果您需要做生产部署，可以根据环境 （Hadoop/K8S） 来选择 Byzer Server 版本或使用 K8S 镜像部署

#### Byzer 引擎版本号
Byzer 引擎（包括 Byzer Notebook， Byzer VSCode Extension 等）会区分已发布版本和 Nightly Build 版本：
- **Nightly Build 版本**：每日基于主分支自动构建的最新版本，会包含最新的功能 Feature 但可能未经过测试
- **已发布版本**: 经过测试的发布版本

> 目前只有官方下载站点和 Docker Hub 会包含 Nightly Build 的版本产品包

Byzer 引擎的版本号规范为 `byzer-lang-{spark-version}-{byzer-version}.tar.gz`, 其中 `{spark-version}` 是 Byzer 引擎内置的 Spark 版本号。如下图所示

<p align="center">
    <img src="/byzer-lang/zh-cn/installation/images/version.png" alt="name"  width="500"/>
</p>


- 其中 `3.1.1` 代表的是 Spark 的版本，目前 Byzer 支持的 Spark 版本有 `3.1.1` 及 `2.4.3`，后续随着项目迭代，会对 Spark 的版本进行升级，以产品包名为为准
- `latest` 和 `2.2.2` 则代表了 Byzer 引擎的版本号。
    - `latest` 代表该产品包或镜像是 nightly build 版本
    - `2.2.2` 代表该产品包是经过测试发行的正式版本，版本号为 2.2.2

#### Byzer VSCode Extension 版本说明

请参考 [Byzer VSCode Extension 安装说明](/byzer-lang/zh-cn/installation/vscode/byzer-vscode-extension-installation.md) 中版本说明一节。




当使用 Byzer 引擎时，根据不同的用户，可能需要调整 Spark Driver，Executor 以及 JVM 等配置，相关配置信息请参考 [Byzer 引擎参数配置说明](/byzer-lang/zh-cn/installation/configuration/byzer-lang-configuration.md)