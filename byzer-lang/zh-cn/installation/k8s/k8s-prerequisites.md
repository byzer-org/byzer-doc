# K8S 部署前置条件

### 准备 K8S 服务

Byzer 引擎目前没有对 K8S 版本做要求，但一般推荐云厂商提供的 K8S 服务来进行部署，比如 Azure AKS， AWS EKS 等服务。

### 下载 Byzer 引擎 Helm 模板

您可以前往[官方下载站点](https://download.byzer.org/k8s-helm/) ，该路径存放 Byzer 社区部署组件的模板文件，包含如下内容：

```shell
|-- k8s-helm
    |-- byzer-lang
        ｜-- {released-version}
    |-- byzer-notebook
        ｜-- {released-version}
    |-- dolphinscheduler
        ｜-- {released-version}
    |-- nginx-ingress
        ｜-- {released-version}
```

Helm chart 简化了 K8S 部署,  不需要手写 `deployment.yaml`, `service.yaml` `configmap.yaml` 等 yaml 文件，。部署 Byzer 引擎只需要下载对应版本的 byzer-lang 以及 nginx-ingress 的 helm-chart，解压后修改 `values.yaml` 中的参数后，进行部署即可。


### 准备文件存储系统

在 K8S 上部署 Byzer 引擎时，由于是分布式架构，所以需要一个中心化的分布式存储：
- 在 **On Prem 环境**中，可以使用 HDFS 或私有对象存储
- 在**公有云环境**上，一般需要使用该公有云提供的对象存储，比如 Azure Blob Storage，或 AWS S3
- 您也可以使用 **JuiceFS** 作为统一的文件系统，来对底层的存储进行统一的抽象

> **注意**：
> 1. 由于 Byzer 文件读写使用的是 Hadoop Compatible 的 `FileSystem` 接口，所以如果使用厂商提供的对象存储，需要下载该对象存储提供的 SDK Jar 包，并基于 `byzer/byzer-lang-k8s` 重新打包镜像，具体的操作请参考不同云厂商的部署章节
> 2. 本地测试时，可以使用开源的 [minio](https://github.com/minio/minio) 来创建一个对象存储
> 3. 一般情况下，建议使用 （JuiceFS + 对象存储） 的组合，Byzer 引擎对接 JuiceFS， JuiceFS 负责对接对象存储


### 配置 VM Client
该 VM 是作为客户机，来进行和 K8S 服务的交互，进行部署和运维的操作。

- **该虚拟机需要能够和 K8S 服务进行网络连通**
- 建议的操作系统为 Ubuntu 18.04+ 或 CentOS 7.x +
- 需要安装 `kubectl` 以及 `helm` 等工具
- （optional），在使用公有云环境时，还需要安装公有云提供的命令行工具，并在虚拟机中配置公有云托管 K8S 服务的连接信息

#### 在 VM Client 中安装 kubectl

您需要在虚拟机上安装 kubectl，用于和 AKS 服务进行交互。您可以通过下述命令在虚拟机上安装

```shell
## Download kubectl
$ curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
## copy kubectl to a folder which inside PATH 
$ chmod +x kubectl
$ sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

执行 `kubectl version --client` 验证 kubectl 是否安装成功，当您看到输出的 Json 信息说明 kubectl 工具已经成功安装至您的环境中

```shell
$ kubectl version --client
Client Version: version.Info{Major:"1", Minor:"23", GitVersion:"v1.23.4", GitCommit:"e6c093d87ea4cbb530a7b2ae91e54c0842d8308a", GitTreeState:"clean", BuildDate:"2022-02-16T12:38:05Z", GoVersion:"go1.17.7", Compiler:"gc", Platform:"linux/amd64"}
```

> 您可以访问 k8s 官方手册来查看如何在您的操作系统中安装 kubectl 工具 [https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/]([https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)

#### 在 VM Client 中安装 Helm

可自行参考 [helm 官方手册](https://helm.sh/docs/intro/install/) 来自行在 VM 中安装 Helm，您可以选择使用包管理器（如 brew 或 apt）进行安装，也可以下载 helm 的二进制包来进行安装。

我们以 helm 3.8.1 作为示例来进行二进制包的安装

```shell
## download helm 3.8.1 binary package
$ wget https://get.helm.sh/helm-v3.8.1-linux-amd64.tar.gz
## unarchive the tar
$ tar -zxvf helm-v3.8.1-linux-amd64.tar.gz
## move the executable file to /usr/local/bin 
$ sudo mv linux-amd64/helm /usr/local/bin
```

安装完毕后，在 Terminal 中执行 `helm version` 命令，当您看到输出如下时，说明安装成功

```shell
$ helm version                       
version.BuildInfo{Version:"v3.8.1", GitCommit:"5cb9af4b1b271d11d7a97a71df3ac337dd94ad37", GitTreeState:"clean", GoVersion:"go1.17.5"}
```

### 在 K8S 中创建 Namespace 和 Service Account

#### 1. 创建命名空间
K8S 一般使用 **namespace** 隔离多个部门/业务/应用。管理员可以在不同的 namespace 之间设置资源隔离；不同 namespace 之间可以存在同名的资源。

通过下述命令来创建 `byzer` 的命名空间
```shell
## 创建 byzer namespace
$ kubectl create namespace byzer
## 将 byzer namespace 设置为默认空间
$ kubectl config set-context --current --namespace=byzer
```

#### 2. 创建 ServiceAccount 并绑定权限
**ServiceAccount**、 **Role**、**RoleBinding** 是 K8S 中的重要概念，主要用于权限管控。在这里我们创建一个名为 `byzer-sa` 的 ServiceAccount 用于部署， 并将其绑定到名为 `byzer-admin` 的 Role。`byzer-admin` 这个 Role 需要具有较高权限，这样 Byzer 引擎应用可以有权限来创建各类 K8S 对象，比如启动 spark executor 的 pod。

通过执行下述命令创建名为 `byzer-sa` 的 Service Account

```shell
$ kubectl create serviceaccount byzer-sa -n byzer 
```

创建一个 `role.yaml` 文件， 用于定义名为 `byzer-admin` 的 Role，内容如下 

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: byzer-admin
rules:
- apiGroups: [""] 
  resources: ["pods","deployments", "replicas", "secrets", "configmaps","services","ingresses"]
  verbs: ["*"]
```

执行如下命令根据上述 `role.yaml` 来创建 Role，替换命令中的路径为文件的真实路径

```shell
$ kubectl apply /path/to/role.yaml
```

绑定 Service Account `byzer-sa` 到 Role `byzer-admin` 
```shell  
kubectl create rolebinding byer-role-binding --role=byzer-admin --serviceaccount=byzer:byzer-sa --namespace=byzer
```

### Byzer 引擎 K8S 镜像说明

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