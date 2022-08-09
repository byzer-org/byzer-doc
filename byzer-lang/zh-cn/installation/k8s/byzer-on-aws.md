# 在 AWS 通过 EKS 部署 Byzer 引擎

AWS 提供了一个托管的 K8S 服务 EKS，用户可以直接使用 EKS 来部署管理应用。

本章节以 AWS CN 为例，来介绍如何在云上部署 Byzer 引擎。请确保在开始部署之前，您有阅读并根据 [K8S 部署前置条件](/byzer-lang/zh-cn/installation/k8s/k8s-prerequisites.md) 完成了前置条件中的准备工作

### 1. 其他环境准备

- [eksctl](https://docs.amazonaws.cn/eks/latest/userguide/eksctl.html#installing-eksctl)
- [kubectl](https://docs.amazonaws.cn/eks/latest/userguide/install-kubectl.html)
- [aws cli](https://docs.amazonaws.cn/cli/latest/userguide/getting-started-install.html)
- [helm](https://helm.sh/docs/intro/install/)

### 2. 部署 Byzer 套件

#### i. 安装 Helm

```Shell
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```

<center>
	<img src="/byzer-lang/zh-cn/installation/k8s/images/aws_helm_install.png" style="zoom: 50%;" />
</center>

查看 kubectl 信息

```YAML
kubectl cluster-info
```

<center>
	<img src="/byzer-lang/zh-cn/installation/k8s/images/aws_kubectl_cluster_info.png" style="zoom: 50%;" />
</center>

#### ii. 创建 Namespace

```Shell
# kubectl create namespace <namespace>
kubectl create namespace byzer-eks-demo-yaml
```

#### iii. 创建 service account

```Shell
## kubectl create serviceaccount <service_account_name> -n <namespace>
kubectl create serviceaccount byzer -n byzer-eks-demo-yaml
```

<center>
	<img src="/byzer-lang/zh-cn/installation/k8s/images/aws_kubectl_serviceaccount_create.png" style="zoom: 50%;" />
</center>

#### iv. 创建 Role 和 Rolebinding

创建 Role byzer-admin 并赋予它在 **byzer-eks-demo-yaml** 的 namespace 高权限

[官网文档](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)

创建一个 yarml 文件

```Shell
vim byzer-k8s-role.yaml
```

文本示例

```YAML
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: byzer-aws-admin
rules:
- apiGroups: [""] 
  resources: ["pods","deployments", "replicas", "secrets", "configmaps","services","ingresses"]
  verbs: ["*"]
```

运行这个 yaml 文件

```YAML
kubectl apply -f ./byzer-k8s-role.yaml
```

<center>
	<img src="/byzer-lang/zh-cn/installation/k8s/images/aws_kubectl_apply_2.png" style="zoom: 50%;" />
</center>

绑定 Service Account byzer 到 **byzer-eks-demo-yaml** namespace 的 role **byzer-aws-admin**

```YAML
kubectl create rolebinding byzer-aws-role-binding --role=byzer-aws-admin --serviceaccount=byzer-eks-demo-yaml:byzer --namespace=byzer-eks-demo-yaml
```

<center>
	<img src="/byzer-lang/zh-cn/installation/k8s/images/aws_k8s_created.png" style="zoom: 50%;" />
</center>

#### v. 部署 Byzer 引擎

下载并解压 [Byzer-lang 2.3.0.1 helm chart](https://download.byzer.org/k8s-helm/byzer-lang/2.3.0.1/byzer-lang-helm-charts-2.3.0.1.tgz)

```shell
curl https://download.byzer.org/k8s-helm/byzer-lang/2.3.0.1/byzer-lang-helm-charts-2.3.0.1.tgz | tar -xz
```

<center>
	<img src="/byzer-lang/zh-cn/installation/k8s/images/aws_helm_chart_lang_curl.png" style="zoom: 50%;" />
</center>

解压出目录 byzer-lang 的子目录中有一个 values.yaml 文件，这是部署的配置文件。

`values.yaml` 包含 Byzer-lang 镜像 ，Byzer-lang Driver 和Executor 资源大小，对象存储等。我们给出一个例子：

需要注意的是

- storage 和 SecretKey 即使没用也不能删掉，且 value 必须是 base64 编码的

- clusterUrl 的值为 `kubectl cluster-info`获取的 `Kubernetes master` base64 编码后的值

<center>
	<img src="/byzer-lang/zh-cn/installation/k8s/images/aws_kubectl_cluster_info.png" style="zoom: 50%;" />
</center>


| 参数                               | 说明                                                         |
| ---------------------------------- | ------------------------------------------------------------ |
| **fs.defaultFS**                   | 预先申请的 AWS S3 的地址，Byzer-lang 基于 HDFS API 访问它。格式为 `**s3a://<bucket>**` 。 |
| **fs.AbstractFileSystem.s3a.impl** | S3 为 `org.apache.hadoop.fs.s3a.S3A`                         |
| **fs.s3a.access.key**              | AWS 的 accessKey                                             |
| **fs.s3.secret.key**               | AWS 的 secretKey                                             |
| **fs.s3a.endpoint**                | S3 的 endpoint                                               |
| **fs.s3a.region**                  | S3 的 bucket 的所在区域                                      |
| **clusterUrl**                     | AWS EKS 的 API Server 地址，在 EKS 管理页面查询，需要将对应地址经过 base 64 编码 |
| **storage.SecretKey**              | Azure Blob 的 Secret key，S3 不用，但不能删除这一行配置      |
| **spark.driver.memory**            | Driver 内存，例如 `16g`；由于 Byzer Driver 承担的负载较重，建议 16g 起步 |
| **spark.driver.cores**             | Driver CPU 核数，例如 `4`；在生产上建议 cpu/mem 比为 1:4     |
| **spark.driver.maxResultSize**     | Driver 端结果集上限，例如 `2g`                               |
| **spark.executor.memory**          | Executor 内存，例如 `4g`                                     |
| **spark.executor.cores**           | Executor CPU 核数，例如 `1`；在生产上建议 cpu/mem 比为 1:4   |
| **spark.executor.instances**       | Executor 数量，例如 `2`；此值建议根据生产负载来规划，建议 4 个起步 |
| **streaming.datalake.path**        | Byzer Engine 内置的 DeltaLake 的工作目录，引擎会在 Azure Blob 上自动创建，例如 `/byzer/_delta`， 无需事先创建。 |



测试 `values.yaml`

- install 表示安装一个 helm release

- dry-run 表示仅解析values ，生成 deployment 等，但不真正部署

```Shell
## 需要进入到 byzer-lang chart 目录
cd ./byzer-lang

helm upgrade -i --dry-run byzer-lang ./ -f values.yaml --namespace byzer-eks-demo-yaml
```

<center>
	<img src="/byzer-lang/zh-cn/installation/k8s/images/aws_yaml_lang.png" style="zoom: 50%;" />
</center>

测试无误后执行以下命令部署

```Shell
helm upgrade -i byzer-lang ./ -f values.yaml --namespace byzer-eks-demo-yaml
```

<center>
	<img src="/byzer-lang/zh-cn/installation/k8s/images/aws_helm_upgrade_lang.png" style="zoom: 50%;" />
</center>

#### vi. 安装 nginx ingress

Get Repo Info

```console
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
```

Install Chart
>**Important:** only helm3 is supported

```console
helm install [RELEASE_NAME] ingress-nginx/ingress-nginx
```

安装完成后执行 `kubectl -n ingress-nginx get svc`获取 `EXTERNAL-IP`，在 负载均衡中搜索对应名称。

#### vii. 部署 Dolphinscheduler

下载并解压缩 DolphinScheduler helm  chart

```Shell
wget -c https://download.byzer.org/k8s-helm/dolphinscheduler/1.3.0/dolphinscheduler-1.3.0.tgz -O - | tar -xz
```

进入 DolphinScheduler helm  charts 目录

```Shell
cd dolphinscheduler/
```

values.yaml 配置项

| 参数                      | 说明                                                         |
| ------------------------- | ------------------------------------------------------------ |
| externalDatabase.host     | AWS RDS 的 Endpoint                                          |
| externalDatabase.port     | 数据库端口号                                                 |
| externalDatabase.username | 数据库用户名                                                 |
| externalDatabase.password | 数据库密码                                                   |
| externalDatabase.params   | 数据库参数，如 `useUnicode=true&characterEncoding=UTF-8&useSSL=false` |

测试 values.yaml

```Shell
helm upgrade -i --dry-run dolphinscheduler ./ -f values.yaml --namespace byzer-eks-demo-yaml
```

测试成功后开始部署

```Shell
helm upgrade -i dolphinscheduler ./ -f values.yaml --namespace byzer-eks-demo-yaml
```

根据 [使用手册](https://docs.byzer.org/#/byzer-notebook/zh-cn/schedule/install_dolphinscheduler) 的「[对接 Byzer Notebook](https://docs.byzer.org/#/byzer-notebook/zh-cn/schedule/install_dolphinscheduler?id=对接-byzer-notebook)」章节使用一下命令在本机访问 dolphinscheduler，访问地址：http://localhost:12345/dolphinscheduler

```Shell
kubectl port-forward svc/dolphinscheduler-api 12345:12345
kubectl port-forward -n byzer-eks-demo-yaml svc/dolphinscheduler-api 12345:12345
```

#### vii. 部署 Byzer Notebook

下载 Notebook helm chart 并解压

```Shell
curl https://download.byzer.org/k8s-helm/byzer-notebook/1.2.0/byzer-notebook-helm-charts-1.2.0.tgz | tar -xz
```

<center>
	<img src="/byzer-lang/zh-cn/installation/k8s/images/aws_helm_chart_notebook.png" style="zoom: 50%;" />
</center>

进入 Notebook helm chart 目录

```Shell
cd byzer-notebook/
```

values.yaml 配置项

| 参数                             | 说明                                                         |
| -------------------------------- | ------------------------------------------------------------ |
| notebook.security.key            | 私钥，用胡注册时用这个 token 进行加解密                      |
| notebook.mlsql.engine-url        | 引擎地址，这里使用 k8s 命名规则，`http://<service_name>.<namespace>:<port>`。如：`**http://byzer-lang-service.byzer-eks-demo-yaml:9003**` |
| notebook.scheduler.scheduler-url | 调度 api 地址，同样是 k8s 命名规则，如：`**http://dolphinscheduler-api.byzer-eks-demo-yaml:12345/dolphinscheduler**` |
| notebook.scheduler.auth-token    | 调度的 token，获取方法见 [对接 Byzer Notebook](https://docs.byzer.org/#/byzer-notebook/zh-cn/schedule/install_dolphinscheduler?id=对接-byzer-notebook)，使用如下命令在本机访问 dolphinscheduler，访问地址：http://localhost:12345/dolphinscheduler<br />- kubectl port-forward svc/dolphinscheduler-api 12345:12345<br />- kubectl port-forward -n byzer-eks-demo-yaml svc/dolphinscheduler-api 12345:12345 |
| notebook.scheduler.callback-url  | 调度的 notebook 回调地址,同样是 k8s 命名规则，如：`**http://byzer-notebook.byzer-eks-demo-yaml:9002**` |
| notebook.database.*              | notebook 的 mysql 相关配置                                   |

`mlsql.engine-url`的 value 的规则：

类似的都是该规则

```Shell
http://{service name}.{namespace}:{port}
http://byzer-lang-service.byzer-eks-demo-yaml:9003
```

<center>
	<img src="/byzer-lang/zh-cn/installation/k8s/images/aws_kubectl-svc_get.png" style="zoom: 50%;" />
</center>

测试

```Shell
helm upgrade -i --dry-run byzer-notebook ./ -f values.yaml --namespace byzer-eks-demo-yaml
```

<center>
	<img src="/byzer-lang/zh-cn/installation/k8s/images/aws_helm_notebook_upgrade.png" style="zoom: 50%;" />
</center>

测试完成后去掉 `dry-run` 部署

```Shell
helm upgrade -i byzer-notebook ./ -f values.yaml --namespace byzer-eks-demo-yaml
```

<center>
	<img src="/byzer-lang/zh-cn/installation/k8s/images/aws_helm_notebook_upgrade.png" style="zoom: 50%;" />
</center>

查看 pod 是否正常运行

```Shell
kubectl -n byzer-eks-demo-yaml get pod
```

### 4. 验证 Byzer 套件

```Shell
## 查看 EXTERNAL-IP，通过 EXTERNAL-IP 让用户自己配 DNS
kubectl -n ingress-nginx get svc
```

<center>
	<img src="/byzer-lang/zh-cn/installation/k8s/images/aws_ingress_nginx_svc_get_n.png" style="zoom: 50%;" />
</center>

登录对应地址查看 Byzer Notebook 的各个功能

### FAQ：

#### 1. Kubernetes 平台 常用命令
##### 环境准备

安装kubectl 参考 [kubectl Install Doc](https://kubernetes.io/docs/tasks/tools/)

##### 常用操作

###### i. 查看 pod/configmap/service/ingress 等资源
```shell
kubectl -n <NAMESPACE_NAME> get <RESOURCE_NAME>
```

###### ii. 查看 pod log4
```shell
# 查看pod所有log
kubectl -n <NAMESPACE_NAME> logs <POD_NAME>
# 查看最新50行
kubectl -n <NAMESPACE_NAME> logs -tail=50 <POD_NAME>
```

###### iii. 进入pod
```shell
kubectl -n <NAMESPACE_NAME> exec -ti <POD_NAME> -- /bin/bash
# 如果pod中存在多个container
kubectl -n <NAMESPACE_NAME> exec -ti <POD_NAME> -c <CONTAINER_NAME> -- /bin/bash
```

###### iv. 查看pod无法正常启动原因
```shell
kubectl -n <NAMESPACE_NAME> describe pod/<POD_NAME>
```

###### v. 本地调试时，端口转发
```shell
kubectl -n <NAMESPACE_NAME> port-forward service/<SERVICE_NAME> <LOCAL_PORT>:<REMOTE_PORT>
# 例子
kubectl get service -n mongo
##############
NAME    TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)     AGE
mongo   ClusterIP   10.96.41.183   <none>        27017/TCP   11s
##############

kubectl -n mongo port-forward service/mongo 28015:27017

# 本地连接mongo
mongosh --port 28015
```

#### 2. Dolphinscheduler 部署后链接不上 mysql
<center>
	<img src="/byzer-lang/zh-cn/installation/k8s/images/aws_mysql_connect_failed.png" style="zoom: 50%;" />
</center>

values.yaml 增加配置 useSSL=false

```YAML
# 请使用 Byzer 维护的镜像，支持 MySQL。
image:
  repository: "byzer/dolphinscheduler"
  tag: "1.3.9-mysql-driver"
  
# MySQL
externalDatabase:
  type: "mysql"
  driver: "com.mysql.jdbc.Driver"
  host: ""
  port: "3306"
  username: ""
  password: ""
  database: "dolphinscheduler_k8s"
  params: "useUnicode=true&characterEncoding=UTF-8&useSSL=false"
  
```

#### 3. 多个 Namespace 部署 Notebook 后，如何配置 ingress？

   -  暂不支持

#### 4. 如何在部署的过程中进行 Debug 排查

```shell
[byzer@localhost ~]$ kubectl describe pod -n <namepsace>
## 重试重启
[byzer@localhost ~]$ kubectl rollout restart deploy byzer-engine -n <namepsace>
[byzer@localhost ~]$ kubectl get event -n <namepsace>
[byzer@localhost ~]$ kubectl get pods -n <namepsace>
## 删除一个 pod
[byzer@localhost ~]$ kubectl delete pod <pod_name> -n <namepsace>
## 进入 pod
[byzer@localhost ~]$ kubectl exec -ti <pod_name> -n <namepsace> -- /bin/sh
## 查看 deployment 详情
[byzer@localhost ByzerDemo]$ kubectl describe deployment -n <namepsace>
```