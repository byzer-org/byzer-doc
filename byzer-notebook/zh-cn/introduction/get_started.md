# 快速开始

本章节将会介绍如何使用 Docker 镜像环境快速体验 Byzer Notebook。

### 前置条件

[安装 Docker](https://www.docker.com/products/docker-desktop)，如果已安装请忽略。

### 安装 Sandbox 镜像

1. 获取镜像并运行容器

```shell
docker pull byzer/byzer-sandbox:3.1.1-<Byzer Release 版本号>
```
   
使用 docker 命令启动 Spark 3.1.1 版 Sandbox 容器:

```shell
docker run -d \
-p 3306:3306 \
-p 9002:9002 \
-p 9003:9003 \
-e MYSQL_ROOT_HOST=% \
-e MYSQL_ROOT_PASSWORD=root \
--name sandbox-3.1.1-<Byzer Release 版本号> \
--restart=always \
byzer/byzer-sandbox:3.1.1-<Byzer Release 版本号>
```


> **注意：**
> `Byzer Release 版本号`请参考 Docker Hub 中  byzer-sandbox 的 Release Tags：https://hub.docker.com/r/byzer/byzer-sandbox/tags
> 参考 [Byzer 引擎部署指引](/byzer-lang/zh-cn/installation/README.md) 一节中
> docker 启动命令中映射了 MySQL 的端口号，如果本地安装了 MySQL 的话，可能会存在端口冲突，需要重新定义一个端口号，如：`-p 13306:3306`

4. 浏览器访问

   访问 `http://localhost:9002` 即可开始体验 Byzer Notebook 了。
   
   初始管理员账号密码为 admin/admin。
   

   
