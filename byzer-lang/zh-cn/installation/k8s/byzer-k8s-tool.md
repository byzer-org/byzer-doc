# 通过 Byzer-K8S 工具部署

Byzer 社区贡献了一个使用 go 语言实现的 Byzer K8S 工具，对 Byzer 的 K8S 做了封装，可以让使用者快速的进行在 K8S 上部署和试用。

项目源代码：[byzer-org/byze-k8s](https://github.com/byzer-org/byzer-k8s)

> 注意
> 1. **当前此工具处于开发测试阶段，并不推荐在生产环境上使用**
> 2. 操作系统建议使用 Linux


### 准备工作


#### 1. 安装 Golang

您可以前往 Golang 的官方网站，根据您的操作系统，[下载并安装 Go 语言环境](https://go.dev/dl/)

> 1. 您可以根据您的操作系统来自行选择安装方式
> 2. 如果您的机器位于 CN 区域，可以设置 goproxy 来使用 CN 区镜像

```shell
$ go env -w GO111MODULE=on
$ go env -w GOPROXY=https://goproxy.cn,direct
$ export GO111MODULE=on
$ export GOPROXY=https://goproxy.cn
```

#### 2. 编译 Byzer K8S 部署工具

通过 git clone 来拉取部署工具到本地

```shell
$ git clone https://github.com/byzer-org/byzer-k8s.git
```

Clone 完毕后，进入到项目的根目录，通过执行下述命令来编译 Byzer K8S 工具

```shell
$ cd byzer-k8s
$ make all
```

编译完成后会在项目根目录中生成一个可执行文件 `byzer-k8s-deploy`


#### 3. 准备 K8S 环境

此处我们使用 `minikube` 来作为 K8S 服务，关于 minikube 的安装，可以参考 [在 Minikube 部署 Byzer 引擎](/byzer-lang/zh-cn/installation/k8s/byzer-on-minikube.md) 一文。

由于此部署工具最后通过 ingress 来暴露 byzer 的服务，所以在 minikube 中需要使用下述命令来启用 ingress 插件

```shell
$ minikube addons enable ingress
```

#### 4. 准备 JuiceFS

Byzer Engine 作为一个 Spark 应用，可以兼容对象存储，HDFS 以及本地存储磁盘。这里我们使用 JuiceFS 作为存储系统，通过 JuiceFS 来管理不同的对象存储。

1. 准备 Redis，JuiceFS 社区版使用 Redis 作为元数据管理工具，所以需要提前准备好 Redis，可通过 docker 来启动一个 Redis 服务

```shell
$ docker run -itd --name redis-server -p 6379:6379  redis
```

2. 准备对象存储，JuiceFS 支持多种对象存储，此处我们选择使用 [minio](https://github.com/minio/minio) 作为示例，minio 是一个开源的兼容 Amazon S3 协议的对象存储，在本机可以通过 docker 来启动一个 minio 服务，需要指定本地挂载的网存储目录，这里我们以 `/home/byzer/minio_data` 为例

```shell
$ docker run -d --name minio \
         -v /home/byzer/minio_data:/data \
         -p 9000:9000 \
         -p 9001:9001 \
         --restart unless-stopped \
         minio/minio server /data --console-address ":9001"

```

服务启动后可以前往 `http://127.0.0.1:9001` 访问 minio console， 用户名和密码分别为 `minioadmin/minioadmin`

3. 安装 JuiceFS 并初始化

前往 [JuiceFS Release](https://github.com/juicedata/juicefs/releases) 下载 JuiceFS 的安装包，下载后将其解压，并进入解压后的目录，执行如下命令对 JuiceFS 进行初始化，该命令会连接 redis 来管理元数据，并在 minio 中创建一个 bucket 名为 `jfs`

```shell
$ ./juicefs format \
  --storage minio \
  --bucket http://127.0.0.1:9000/jfs \
  --access-key minioadmin \
  --secret-key minioadmin \
  redis://127.0.0.1:6379/1 \
  jfs
```

创建完毕后，您可以前往 minio console 查看到该 bucket


#### 5. 进行 Byzer 引擎的部署

上述准备工作完成后，可以通过执行第二步编译后产生的可执行文件 `byzer-k8s-depoly` 进行 Byzer Engine 在 K8S 上的部署，此处我们使用的镜像是 `byzer/byzer-lang-k8s:3.1.1-2.2.2`，关于镜像的选择可以参考 [K8S 镜像部署指南](/byzer-lang/zh-cn/installation/k8s/k8s-deployment.md) 一节

```shell
./byzer-k8s-deploy run \
--kube-config ~/.kube/config \
 --engine-name byzer-engine \
 --engine-image byzer/byzer-lang-k8s:3.1.1-2.2.2 \
 --engine-executor-core-num 1 \
 --engine-executor-num 1  \
 --engine-executor-memory 1024 \
 --engine-driver-core-num 1  \
 --engine-driver-memory 1024 \
 --engine-jar-path-in-container local:///home/deploy/mlsql/libs/streamingpro-mlsql-spark_3.0_2.12-2.2.2.jar  \
 --storage-name jfs \
 --storage-meta-url redis://192.168.0.121:6379/1 
```

上述部分参数说明如下：
参数说明如下:

| 参数名                       | 说明                                                         |
| ---------------------------- | ------------------------------------------------------------ |
| kube-config                  | K8S 配置文件。Byzer-k8S 会读取 K8S ApiServer 地址            |
| engine-name                  | K8S Deployment 名称，请取一个有实际意义的名字                |
| engine-image                 | 请不要改，这是 K8S 从 docker hub 拉取的镜像名                |
| engine-executor-core-num     | 每个 Spark Executor 核数                                     |
| engine-executor-num          | Spark executor 数量                                          |
| engine-executor-memory       | Spark executor 堆内存，单位 MB                               |
| engine-driver-core-num       | Spark driver 核数                                            |
| engine-driver-memory         | Spark driver 堆内存, 单位 MB                                 |
| engine-jar-path-in-container | Byzer-lang jar 在容器内路径，请不要修改。启动 Spark Driver 需要它。 |
| storage-name                 | 执行 JuiceFS format命令时，指定的名称                        |
| storage-meta-url             | JuiceFS 的元数据库连接串          


执行完毕后，Byzer Engine 就部署到 K8S 上了。部署的过程，会经历如下的几个过程：
- 创建 byzer engine 的 configmap
- 在 k8s 中创建 role 并进行绑定
- 创建 byzer engine 的 deployment
- 创建 byzer engine service，将 byzer engine pod 的服务进行端口暴露
- 创建 ingress，将 byzer engine 的端口和服务通过 IP 对外暴露

待部署完成后，你可以通过 `kubectl get ingress` 来查看到 Byzer engine 绑定的 host 和端口， 此时你可以通过在浏览器上访问该 host 和端口进行 Byzer Engine 的访问和体验。

