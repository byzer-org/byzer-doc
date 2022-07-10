# K8S 部署指南

Byzer-lang 作为云原生设计的编程语言，其引擎以及 Byzer Notebook 是支持 K8S 云原生方式部署的，本文主要介绍如何使用 K8S 进行 Byzer 引擎的部署。

> 1. 在 K8S 上部署，要求您了解并熟悉 K8S 相关的部署以及运维等基本知识
> 2. 请先阅读了解部署的方式以及部署前提条件

### 部署方式

- （**推荐**）基于 Helm Chart 的部署方式，可以参考在 Minikube 和 Azure AKS 上部署示例
- 通过 Byzer 社区贡献的 [Byzer-K8S](https://github.com/byzer-org/byzer-k8s) 工具来进行部署体验，详情可参考 [通过 Byzer-K8S 工具部署](/byzer-lang/zh-cn/installation/k8s/byzer-k8s-tool.md) 一节


### 部署前置条件
请前往 [K8S 部署前置条件](/byzer-lang/zh-cn/installation/k8s/k8s-prerequisites.md) 一节进行环境和安装包的准备工作。


### 部署示例
- [在 Minikube 部署 Byzer 引擎](/byzer-lang/zh-cn/installation/k8s/byzer-on-minikube.md) 
- [在 Azure AKS 部署 Byzer 引擎](/byzer-lang/zh-cn/installation/k8s/byzer-on-azure.md)
- [通过 Byzer-K8S 工具部署](/byzer-lang/zh-cn/installation/k8s/byzer-k8s-tool.md) 





