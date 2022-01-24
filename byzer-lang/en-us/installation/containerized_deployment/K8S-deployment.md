# K8S Image deployment guide

This article describes how to deploy and use the byzer-lang K8S image. There are three steps: setup environment, deploy and use functions.

### Setup environment

#### Compile deployment tools

Download and install Go 1.16.7 from the [Go official website](https://golang.org/dl/). This version has been tested.

> We have not tested Go 1.17, please use with caution.

Get the deployment tool code from [Github](https://github.com/byzer-org/byzer-k8s), configure [Goproxy](https://github.com/goproxy/goproxy.cn) and execute the command in the project root directory to start compiling

```shell
make all
```

Then execute the following command:

```shell
./mlsql-deploy -h
```

The result is as follows:

<img src="/byzer-lang/zh-cn/installation/containerized_deployment/images/byzer-k8s_help.PNG" alt="mlsql-deploy_help"/>

#### Install and configure K8S

If you use a personal computer, it is recommended to use [Minikube](https://minikube.sigs.k8s.io/docs/). Becasue it only takes 1 command to start the standalone version of K8S and it supports Linux/MacOS/Windows. After downloading and installing Minikube, execute the following command to start K8S. Configuring the proxy can boost image download speed.

```shell
minikube start
```

To install K8S cluster in production environment, please refer to [13 - MLSQL on k8s(1) - k8s installation](https://mp.weixin.qq.com/s?__biz=MzI5NzEwODUwNw==&mid=2247483782&idx=1&sn=642b036caf8ab6a07ae7cdebe347acc3&chksm=ecbb54f2dbccdde4f6555f4e1c62403f073cf4e50d6aa66034700b2d9a8f97361857e518edc1&scene=21#wechat_redirect).

#### Configure JuiceFS

For more information, read [Byzer-k8s Documentation - Configure JuiceFS](https://github.com/byzer-org/byzer-k8s#juicefs-file-system-setup).

> Note: you need to configure JuiceFS on each K8S server

### Deployment

#### Configure K8S key

This step is important because K8S pulls images from [Docker hub](https://hub.docker.com/) when starting Byzer-lang Driver Pod. Please execute the following command:

```shell
kubectl create secret docker-registry regcred \
--docker-username=<docker hub user name> \
--docker-password=<docker hub password> \
-n default
```

#### Deploy Byzer-lang

Use Byzer-K8s tool to deploy Byzer-lang to the K8S cluster. Examples are as follows:

```shell
# Please modify the directory according to the actual situation
/work/byzer-k8s/byzer-k8s run \
  --kube-config  ~/.kube/config \
  --engine-name mlsql-engine \
  --engine-image byzer/byzer-lang-k8s:3.1.1-2.2.1 \
  --engine-executor-core-num 1 \
  --engine-executor-num 1   \
  --engine-executor-memory 1024 \
  --engine-driver-core-num 1   \
  --engine-driver-memory 1024 \
  --engine-access-token mlsql   \
  --engine-jar-path-in-container local:///home/deploy/mlsql/libs/streamingpro-mlsql-spark_3.0_2.12-2.2.1.jar   \
  --storage-name  jfs \
  --storage-meta-url redis://192.168.50.254:6379/1
```

The parameter descriptions are as follows:

| Parameter Name | Instruction |
|------------------------------|------------------------------------------------|
| kube-config | K8S configuration file, byzer-k8s will read the K8S ApiServer address. |
| engine-name | K8S Deployment Name, please assign a meaningful name. |
| engine-image | Please don't rename, this is the image name pulled by K8S from docker hub. |
| engine-executor-core-num | each Spark Executor's coreness |
| engine-executor-num | number of Spark executors |
| engine-executor-memory | Spark executor heap memory, in MB |
| engine-driver-core-num | Spark driver coreness |
| engine-driver-memory | Spark driver heap memory, in MB |
| engine-access-token | call Token required by byzer-lang API |
| engine-jar-path-in-container | Byzer-lang jar is in the container path, please do not modify it. It is required to start Spark Driver. |
| storage-name | the name that is specified during executing the juicefs format command |
| storage-meta-url | JuiceFS's metadatabase connection strings |

