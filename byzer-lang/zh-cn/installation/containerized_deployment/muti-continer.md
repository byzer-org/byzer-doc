# 多容器部署

### 前置条件

#### 安装 Docker Desktop

需要安装 Docker Desktop，操作步骤 [Sandbox 独立部署](/byzer-lang/zh-cn/installation/containerized_deployment/sandbox-standalone.md) 中有介绍，不再赘述。

#### 下载构建项目

多容器部署需要一个docker-compose.yaml定义构成应用程序的服务,这样它们可以在隔离环境中一起运行。 为了方便使用，请下载 Byzer-build 这个开源项目，在项目中提供了完整的 docker compose 配置，下面将演示具体的操作流程。

下载并获取主干的代码：

```shell
git clone https://github.com/byzer-org/kolo-build.git kolo-build
cd kolo-build && git checkout main && git pull -r origin main
```

#### 设置环境变量

```
## 指定 mysql root 用户密码
export MYSQL_ROOT_PASSWORD=root
## mysql 端口号
export MYSQL_PORT=3306
## byzer 引擎后台管理服务的端口
export KOLO_LANG_PORT=9003
## byzer notebook 客户端端口
export BYZER_NOTEBOOK_PORT=9002
## 当前 byzer 使用的spark版本（用于生成container name）
export SPARK_VERSION=3.1.1
## byzer lang使用的版本（用于生成container name）
export KOLO_LANG_VERSION=2.2.0-SNAPSHOT
## byzer notebook使用的版本（用于生成container name）
export BYZER_NOTEBOOK_VERSION=0.0.1-SNAPSHOT
```

> 注意，上述所有的环境变量我们都提供了默认值，如果您不需要单独定制配置，可以不用设置。


### 使用脚本构建 Byzer Images

运行下面脚本将会构建images到本地仓库，方便后面启动容器使用。

```
sh -x dev/bin/build-images.sh
```

### 使用多个容器部署 Byzer

多容器部署区别于我们前面介绍的 sandbox 独立部署方式，本质上是将多个服务每一个构建为一个镜像，然后使用统一的方式一起启动。这几个服务分别是：

- mysql:8.0-20.04_beta：mysql 数据库，用于存储 byzer-notebook 中的元数据和数据

- byzer-lang：Byzer 的运行时引擎

- byzer-notebook：Byzer 的可视化管理平台

### 执行脚本进行多容器部署

```
sh -x dev/bin/docker-compose-up.sh
```

上面的脚本内部是通过 `docker-compose up` 命令启动服务：

```shell
cd dev/docker

docker-compose up -d
```
