# K8S 镜像部署指南

Byzer-lang 作为云原生设计的编程语言，其引擎以及 Byzer Notebook 是支持 K8S 云原生方式部署的，本文主要介绍如何使用 K8S 进行 Byzer 引擎的部署。

> 在 K8S 上部署，要求您了解并熟悉 K8S 相关的部署以及运维等基本知识

**注意：社区当前正在开发基于 helm chart 的部署方式，当前的部署方式仅供参考使用**


### Byzer 引擎 K8S 镜像

Byzer 社区在 DockerHub 上托管了 Byzer 引擎的 K8s 镜像，您可以前往[Byzer Docker Hub](https://hub.docker.com/u/byzer) 来查看 Byzer 社区托管的镜像文件。

#### 镜像地址

Byzer 引擎的 K8S 镜像地址为 [https://hub.docker.com/r/byzer/byzer-lang-k8s/tags](https://hub.docker.com/r/byzer/byzer-lang-k8s/tags)


你也可以通过 docker pull 命令来将镜像拉取到本地
```shell
docker pull byzer/byzer-lang-k8s:3.1.1-latest
```

#### 镜像版本说明

在 `byzer/byzer-lang-k8s` 镜像中的 tag 中标识着该镜像的版本，关于 Byzer 引擎的版本，请参考 [Byzer 引擎部署指引](/byzer-lang/zh-cn/installation/README.md) 中的 **Byzer 引擎版本说明** 一节。

> 注意：
> 1. 当前 K8S 部署只支持 Spark 3 版本的 Byzer 镜像，Spark 2.+ 不支持
> 2. 一般情况我们推荐使用已发布的正式版本，如 tag 为`3.1.1-2.2.2`，该镜像为正式发布版本 `2.2.2`，如果是测试使用，您也可以使用 Nightly Build 版本，如 `3.1.1-latest`  
> 3. 该镜像内置了 JDK，SPARK 以及 Byzer 的插件


### 支持的 K8S 版本

Byzer 引擎目前没有对 K8S 版本做要求，但一般推荐云厂商提供的 K8S 服务来进行部署，比如 Azure AKS， AWS EKS 等服务。

这里**推荐使用 Kubectl + YAML 配置文件的方式来在 K8S 上进行部署**，如果您想快速进行体验，可以通过 Byzer 社区提供的 [Byzer-K8S](https://github.com/byzer-org/byzer-k8s) 工具来进行部署，详情可参考 [通过 Byzer-K8S 工具部署](/byzer-lang/zh-cn/installation/k8s/byzer-k8s-tool.md) 一节。

推荐您优先阅读 [在 Minikube 部署 Byzer 引擎](/byzer-lang/zh-cn/installation/k8s/byzer-on-minikube.md) 一节来快速进行尝试。

### 支持的存储

在 K8S 上部署 Byzer 引擎时，由于是分布式架构，所以需要一个中心化的分布式存储：
- 在 **On Prem 环境**中，可以使用 HDFS 或私有对象存储
- 在**公有云环境**上，一般需要使用该公有云提供的对象存储，比如 Azure Blob Storage，或 AWS S3
- 您也可以使用 **JuiceFS** 

> **注意**：
> 由于 Byzer 文件读写使用的是 Hadoop Compatible 的 `FileSystem` 接口，所以如果使用厂商提供的对象存储，需要下载该对象存储提供的 SDK Jar 包，并基于 `byzer/byzer-lang-k8s` 重新打包镜像，具体的操作请参考对应部署章节