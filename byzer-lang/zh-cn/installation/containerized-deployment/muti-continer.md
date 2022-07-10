# 多容器部署

### 前置条件

#### 安装 Docker Desktop

更多信息请参考 [Sandbox 独立部署](/byzer-lang/zh-cn/installation/containerized-deployment/sandbox-standalone.md)。

#### 下载构建项目

多容器部署需要一个 docker-compose.yaml 定义构成应用程序的服务，这样它们可以在隔离环境中一起运行。 为了方便使用，请下载 byzer-build 这个开源项目，在项目中提供了完整的 docker compose 配置，下面将演示具体的操作流程。

下载并获取 main 的代码：

```shell
git clone https://github.com/byzer-org/byzer-build.git byzer-build
cd byzer-build && git checkout main && git pull -r origin main
```

#### 设置环境变量

```
## 指定 mysql root 用户密码
export MYSQL_ROOT_PASSWORD=root
## mysql 端口号
export MYSQL_PORT=3306
## byzer 引擎后台管理服务的端口
export BYZER_LANG_PORT=9003
## byzer notebook 客户端端口
export BYZER_NOTEBOOK_PORT=9002
## 当前 byzer 使用的 spark 版本（用于生成 container name）
export SPARK_VERSION=3.1.1
## byzer lang 使用的版本（用于生成 container name），如果想直接体验最新版本，请使用 latest
export BYZER_LANG_VERSION=<Byzer-lang Relase版本号>
## byzer notebook 使用的版本（用于生成 container name），如果想直接体验最新版本，请使用 latest
export BYZER_NOTEBOOK_VERSION=<Byzer-notebook Relase版本号>
```

> 注意：上述所有的环境变量我们都提供了默认值，如果您不需要单独定制配置，可以不用设置。

其中`Byzer-lang Relase版本号`请参考Byzer lang的Release Tags：https://github.com/byzer-org/byzer-lang/tags

`Byzer Notebook Relase版本号`请参考Byzer notebook的Release Tags：https://github.com/byzer-org/byzer-notebook/tags

获取方式：例如最新的tag为 `v2.2.1`，则使用版本号 `2.2.1`，那么参数应该设置为 `export BYZER_LANG_VERSION=2.1.1`。





### 使用脚本构建 Byzer Images

运行下面脚本将会构建 images 到本地仓库，方便后面启动容器使用。

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

上面的脚本内部是通过 `docker-compose up` 命令启动服务（如果不关心执行方式可以执行上面的脚本即可）：

```shell
cd dev/docker

docker-compose up -d
```

> 注意：docker-compose中提供了mlsql端口号的默认值，如果本地安装了mysql的话，可能会存在端口冲突，需要重新定义一个端口号，如：`export MYSQL_PORT=13306`

### 体验 Byzer 功能

浏览器[登录](http://localhost:9002)，在用户注册界面，输入用户名和密码，点击 **Create a New Notebook - Create**，进入 Notebook 使用界面，
我们提供了一些快速入门的 demo，方便您一览 Byzer 的基础功能。


![](/byzer-lang/zh-cn/installation/containerized-deployment/images/img.png)