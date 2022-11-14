# 容器化部署操作指南

Byzer 提供了多种部署方式，方便您在不同的场景下灵活构建和使用（点击可查看几种部署方式详情）：

  - [Sandbox 独立部署](/byzer-lang/zh-cn/installation/containerized-deployment/sandbox-standalone.md)：Sandbox 镜像统一将 Byzer 引擎、Byzer-notebook 和 MLSQL 打包到一个镜像中，用于快速的在本地体验 Byzer，如果您需要将多个组件分开部署，可以使用 `Sandbox 多容器部署`方式。

  - [多容器部署](/byzer-lang/zh-cn/installation/containerized-deployment/muti-continer.md)：多容器部署方式会将 Byzer 引擎、Byzer-notebook 和 mysql 三个镜像通过 docker-compose 统一编排、部署，支持了健康检查、生命周期管理等特性。


