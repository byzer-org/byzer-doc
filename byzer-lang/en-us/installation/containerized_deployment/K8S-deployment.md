# K8S Image deployment

This article describes how to deploy and use the Byzer-Lang K8S image. There are three steps: setup environment, deploy and then experience Byzer functions.

### Setup environment

#### Compile deployment tools

Download and install Go 1.16.7 from the [Go official website](https://golang.org/dl/), as this version has been tested.

> We have not tested Go 1.17 yet, please use it with caution.

Clone the deployment tool code from [Github](https://github.com/byzer-org/byzer-k8s), configure [Goproxy](https://github.com/goproxy/goproxy.cn), and execute the command in the project root directory to start compiling:

```shell
make all
```

Then execute the following command:

```shell
./mlsql-deploy -h
```

The result is as follows:

<img src="/Byzer-Lang/zh-cn/installation/containerized_deployment/images/byzer-k8s_help.PNG" alt="mlsql-deploy_help"/>

#### Install and configure K8S

If you are using your personal computer, it is recommended to use [Minikube](https://minikube.sigs.k8s.io/docs/). Because you only need to run one command to start the standalone version of K8S and it supports Linux/macOS/Windows. We have successfully deployed Ubuntu 20.04 minikube 1.23.0. After downloading and installing Minikube, execute the following command to start K8S. Note: You can configure a proxy to accelerate the image download speed.

```shell
minikube start
```

To install K8S cluster in production environment, please refer to [13 - MLSQL on k8s(1) - k8s installation](https://mp.weixin.qq.com/s?__biz=MzI5NzEwODUwNw==&mid=2247483782&idx=1&sn=642b036caf8ab6a07ae7cdebe347acc3&chksm=ecbb54f2dbccdde4f6555f4e1c62403f073cf4e50d6aa66034700b2d9a8f97361857e518edc1&scene=21#wechat_redirect).

#### Configure JuiceFS

For more information, see [Byzer-k8s Documentation - Configure JuiceFS](https://github.com/byzer-org/byzer-k8s#juicefs-file-system-setup).

> Note: you need to configure `JuiceFS` on each K8S server

### Deployment

#### Configure K8S key

As K8S will pull images from [Docker hub](https://hub.docker.com/) when starting Byzer-lang Driver Pod, that's why we need to configure the  K8S key. Please execute the following command:

```shell
kubectl create secret docker-registry regcred \
--docker-username=<docker hub user name> \
--docker-password=<docker hub password> \
-n default
```

#### Deploy Byzer-lang

Use Byzer-K8s tool to deploy Byzer-Lang to the K8S cluster. Examples are as follows:

```shell
# Please modify the directory according to the actual situation
/work/byzer-k8s/byzer-k8s run \
  --kube-config  ~/.kube/config \
  --engine-name mlsql-engine \
  --engine-image byzer/Byzer-Lang-k8s:3.1.1-2.2.1 \
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
| engine-image | Do not change. This is the image name pulled by K8S from docker hub. |
| engine-executor-core-num | core number of each Spark Executor |
| engine-executor-num | number of Spark executors |
| engine-executor-memory | Spark executor heap memory, in MB |
| engine-driver-core-num | core number of Spark driver |
| engine-driver-memory | Spark driver heap memory, in MB |
| engine-access-token | token required by call Byzer-Lang API |
| engine-jar-path-in-container | Do not change. Byzer-lang jar is in the container path,  required when start Spark Driver. |
| storage-name | name specified when executing the juicefs format command |
| storage-meta-url | metadatabase connection strings of JuiceFS |

