## Byzer on k8s（2） - Spark on k8s
下面将基于 spark native 方式部署，分别讲解如下三种模式：
 
1. spark submit 从物理机 cluster 模式提交
2. spark submit 从物理机 client 模式提交
3. spark submit 从 container client 模式提交

### 首先，先构建 spark 的镜像，因为镜像要被共享，因此要放到一个镜像库中，docker 搭一个镜像库：
	
```shell
# https://hub.docker.com/_/registry
docker pull registry
docker run --insecure-registry -d -p 5000:5000 --restart always --name registry registry:2
 
 
# 可以通过curl来访问：
curl -XGET http://172.16.2.66:5000/v2/_catalog
curl -XGET http://172.16.2.66:5000/v2/mlsql/tags/list（查看 Byzer 库下的 tags）
```
* 在 Spark 包下，生成镜像并推送到镜像库：

```shell
 tar xvf spark-3.0.2-SNAPSHOT-bin-hadoop2.7.tar
 cd spark-3.0.2-SNAPSHOT-bin-hadoop2.7
  
 docker build -t 172.16.2.66:5000/spark:v3.0 -f kubernetes/dockerfiles/spark/Dockerfile .
 docker push 172.16.2.66:5000/spark:v3.0
 
 
docker images
REPOSITORY                                                       TAG             IMAGE ID       CREATED         SIZE
172.16.2.66:5000/spark                                           v3.0            ff6692727fad   5 days ago      500MB
 
 
curl -XGET http://172.16.2.66:5000/v2/spark/tags/list
{"name":"spark","tags":["v3.0"]}
```
* 建立 Spark 访问 k8s apiserver 账户：

```
kubectl create serviceaccount spark
kubectl create clusterrolebinding spark-role --clusterrole=create --serviceaccount=default:spark --namespace=defaul
```
	
#### 1. spark submit 从物理机 cluster 模式提交：

```shell
./bin/spark-submit \
--master k8s://https://172.16.2.62:6443 \
--deploy-mode cluster \
--name spark-pi \
--class org.apache.spark.examples.SparkPi \
--conf spark.executor.instances=2 \
--conf spark.kubernetes.container.image=172.16.2.66:5000/spark:v3.0 \
--conf spark.kubernetes.driver.pod.name=spark-pi-driver-ca \
--conf spark.kubernetes.namespace=default \
--conf spark.kubernetes.authenticate.driver.serviceAccountName=spark \
--conf spark.kubernetes.authenticate.submission.caCertFile=/opt/kubernetes/ssl/ca.pem \
local:///opt/spark/examples/jars/spark-examples_2.12-3.0.2-SNAPSHOT.jar'
```
会遇到如下错误：`http: server gave HTTP response to HTTPS client`。

在 `/etc/docker/daemon.json` 增加：

```json
{
  "registry-mirrors": ["https://b9pmyelo.mirror.aliyuncs.com"],
  "insecure-registries":["172.16.2.66:5000"]
}
```

注意这两个参数：

spark.kubernetes.authenticate.driver.serviceAccountName  指定 apiserver 的账户
spark.kubernetes.authenticate.submission.caCertFile      apiserver 的 ca 证书
	
#### 2. spark submit 从物理机 client 模式提交
```shell

./bin/spark-submit --master k8s://https://172.16.2.62:6443 \
            --deploy-mode client \
            --name spark-pi \
            --class org.apache.spark.examples.SparkPi \
            --conf spark.kubernetes.namespace=default \
            --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark \
            --conf spark.executor.instances=1 \
            --conf spark.kubernetes.container.image=172.16.2.66:5000/spark:v3.0 \
            --conf spark.driver.host=172.16.2.62 \
            --conf spark.kubernetes.authenticate.caCertFile=/opt/kubernetes/ssl/ca.pem \
            /root/k8s/spark/spark-3.0.2-SNAPSHOT-bin-hadoop2.7/examples/jars/spark-examples_2.12-3.0.2-SNAPSHOT.jar
 
 
spark.kubernetes.authenticate.driver.serviceAccountName  指定 apiserver 的账户
spark.kubernetes.authenticate.caCertFile                 apiserver 的 ca 证书，这个参数和 cluster 模式不同，
spark.driver.host                                        client 所在机器的地址           

```

#### 3. spark submit 从 container client 模式提交

```
cat > spark-hello.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: spark-hello
  namespace: default
spec:
  selector:
    matchLabels:
      app: spark-hello
  strategy:
    rollingUpdate:
      maxUnavailable: 0
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: spark-hello
    spec:
      containers:
      - name: spark-hello     
        args:
          - >-
            echo "/opt/spark/bin/spark-submit --master k8s://https://172.16.2.62:6443
            --deploy-mode client
            --name spark-pi
            --class org.apache.spark.examples.SparkPi
            --conf spark.kubernetes.namespace=default
            --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark
            --conf spark.jars.ivy=/tmp/.ivy
            --conf spark.executor.instances=2
            --conf spark.kubernetes.container.image=172.16.2.66:5000/spark:v3.0
            --conf spark.driver.host=$POD_IP
            local:///opt/spark/examples/jars/spark-examples_2.12-3.0.2-SNAPSHOT.jar" | bash
        command:
          - /bin/sh
          - '-c'
        env:
          - name: POD_IP
            valueFrom:
              fieldRef:
                fieldPath: status.podIP          
        image: '172.16.2.66:5000/spark:v3.0'
        imagePullPolicy: Always
EOF
 
 
kubectl create -f spark-hello.yaml
 
 
kubectl get pods
NAME                                       READY   STATUS    RESTARTS   AGE
spark-hello-7c697b87cc-2n75m               0/1     Error     1          10
```
果然不是一帆风顺，来看看日志吧：

```
kubectl logs spark-hello-7c697b87cc-2n75m
 
 
21/02/07 09:42:11 INFO KerberosConfDriverFeatureStep: You have not specified a krb5.conf file locally or via a ConfigMap. Make sure that you have the krb5.conf locally on the driver image.
Exception in thread "main" java.io.IOException: failure to login
  at org.apache.hadoop.security.UserGroupInformation.loginUserFromSubject(UserGroupInformation.java:841)
  at org.apache.hadoop.security.UserGroupInformation.getLoginUser(UserGroupInformation.java:777)
  at org.apache.hadoop.security.UserGroupInformation.getCurrentUser(UserGroupInformation.java:650)
  at org.apache.spark.util.Utils$.$anonfun$getCurrentUserName$1(Utils.scala:2412)
  at scala.Option.getOrElse(Option.scala:189)
  at org.apache.spark.util.Utils$.getCurrentUserName(Utils.scala:2412)
  at org.apache.spark.deploy.k8s.features.BasicDriverFeatureStep.configurePod(BasicDriverFeatureStep.scala:119)
  at org.apache.spark.deploy.k8s.submit.KubernetesDriverBuilder.$anonfun$buildFromFeatures$3(KubernetesDriverBuilder.scala:59)
  at scala.collection.LinearSeqOptimized.foldLeft(LinearSeqOptimized.scala:126)
  at scala.collection.LinearSeqOptimized.foldLeft$(LinearSeqOptimized.scala:122)
  at scala.collection.immutable.List.foldLeft(List.scala:89)
  at org.apache.spark.deploy.k8s.submit.KubernetesDriverBuilder.buildFromFeatures(KubernetesDriverBuilder.scala:58)
  at org.apache.spark.deploy.k8s.submit.Client.run(KubernetesClientApplication.scala:100)
  at org.apache.spark.deploy.k8s.submit.KubernetesClientApplication.$anonfun$run$3(KubernetesClientApplication.scala:235)
  at org.apache.spark.deploy.k8s.submit.KubernetesClientApplication.$anonfun$run$3$adapted(KubernetesClientApplication.scala:229)
  at org.apache.spark.util.Utils$.tryWithResource(Utils.scala:2539)
  at org.apache.spark.deploy.k8s.submit.KubernetesClientApplication.run(KubernetesClientApplication.scala:229)
  at org.apache.spark.deploy.k8s.submit.KubernetesClientApplication.start(KubernetesClientApplication.scala:202)
  at org.apache.spark.deploy.SparkSubmit.org$apache$spark$deploy$SparkSubmit$$runMain(SparkSubmit.scala:928)
  at org.apache.spark.deploy.SparkSubmit.doRunMain$1(SparkSubmit.scala:180)
  at org.apache.spark.deploy.SparkSubmit.submit(SparkSubmit.scala:203)
  at org.apache.spark.deploy.SparkSubmit.doSubmit(SparkSubmit.scala:90)
  at org.apache.spark.deploy.SparkSubmit$$anon$2.doSubmit(SparkSubmit.scala:1007)
  at org.apache.spark.deploy.SparkSubmit$.main(SparkSubmit.scala:1016)
  at org.apache.spark.deploy.SparkSubmit.main(SparkSubmit.scala)
Caused by: javax.security.auth.login.LoginException: java.lang.NullPointerException: invalid null input: name
  at jdk.security.auth/com.sun.security.auth.UnixPrincipal.<init>(Unknown Source)
  at jdk.security.auth/com.sun.security.auth.module.UnixLoginModule.login(Unknown Source)
  at java.base/javax.security.auth.login.LoginContext.invoke(Unknown Source)
  at java.base/javax.security.auth.login.LoginContext$4.run(Unknown Source)
  at java.base/javax.security.auth.login.LoginContext$4.run(Unknown Source)
  at java.base/java.security.AccessController.doPrivileged(Native Method)
  at java.base/javax.security.auth.login.LoginContext.invokePriv(Unknown Source)
  at java.base/javax.security.auth.login.LoginContext.login(Unknown Source)
  at org.apache.hadoop.security.UserGroupInformation.loginUserFromSubject(UserGroupInformation.java:815)
  at org.apache.hadoop.security.UserGroupInformation.getLoginUser(UserGroupInformation.java:777)
  at org.apache.hadoop.security.UserGroupInformation.getCurrentUser(UserGroupInformation.java:650)
  at org.apache.spark.util.Utils$.$anonfun$getCurrentUserName$1(Utils.scala:2412)
  at scala.Option.getOrElse(Option.scala:189)
  at org.apache.spark.util.Utils$.getCurrentUserName(Utils.scala:2412)
  at org.apache.spark.deploy.k8s.features.BasicDriverFeatureStep.configurePod(BasicDriverFeatureStep.scala:119)
  at org.apache.spark.deploy.k8s.submit.KubernetesDriverBuilder.$anonfun$buildFromFeatures$3(KubernetesDriverBuilder.scala:59)
  at scala.collection.LinearSeqOptimized.foldLeft(LinearSeqOptimized.scala:126)
  at scala.collection.LinearSeqOptimized.foldLeft$(LinearSeqOptimized.scala:122)
  at scala.collection.immutable.List.foldLeft(List.scala:89)
  at org.apache.spark.deploy.k8s.submit.KubernetesDriverBuilder.buildFromFeatures(KubernetesDriverBuilder.scala:58)
  at org.apache.spark.deploy.k8s.submit.Client.run(KubernetesClientApplication.scala:100)
  at org.apache.spark.deploy.k8s.submit.KubernetesClientApplication.$anonfun$run$3(KubernetesClientApplication.scala:235)
  at org.apache.spark.deploy.k8s.submit.KubernetesClientApplication.$anonfun$run$3$adapted(KubernetesClientApplication.scala:229)
  at org.apache.spark.util.Utils$.tryWithResource(Utils.scala:2539)
  at org.apache.spark.deploy.k8s.submit.KubernetesClientApplication.run(KubernetesClientApplication.scala:229)
  at org.apache.spark.deploy.k8s.submit.KubernetesClientApplication.start(KubernetesClientApplication.scala:202)
  at org.apache.spark.deploy.SparkSubmit.org$apache$spark$deploy$SparkSubmit$$runMain(SparkSubmit.scala:928)
  at org.apache.spark.deploy.SparkSubmit.doRunMain$1(SparkSubmit.scala:180)
  at org.apache.spark.deploy.SparkSubmit.submit(SparkSubmit.scala:203)
  at org.apache.spark.deploy.SparkSubmit.doSubmit(SparkSubmit.scala:90)
  at org.apache.spark.deploy.SparkSubmit$$anon$2.doSubmit(SparkSubmit.scala:1007)
  at org.apache.spark.deploy.SparkSubmit$.main(SparkSubmit.scala:1016)
  at org.apache.spark.deploy.SparkSubmit.main(SparkSubmit.scala)
 
 
  at java.base/javax.security.auth.login.LoginContext.invoke(Unknown Source)
  at java.base/javax.security.auth.login.LoginContext$4.run(Unknown Source)
  at java.base/javax.security.auth.login.LoginContext$4.run(Unknown Source)
  at java.base/java.security.AccessController.doPrivileged(Native Method)
  at java.base/javax.security.auth.login.LoginContext.invokePriv(Unknown Source)
  at java.base/javax.security.auth.login.LoginContext.login(Unknown Source)
  at org.apache.hadoop.security.UserGroupInformation.loginUserFromSubject(UserGroupInformation.java:815)
  ... 24 more
  
```

仔细分析了一下，就是在 container 中 spark submit 的用户没有指定名字。然后有了两个假设：

构建容器的时候是否可以指定用户

deployment 启动容器的时候是否可以指定用户

spark 的 Dockerfile:

```shell
# Specify the User that the actual main process will run as
USER ${spark_uid}
```
网上说这样指定就可以通过，但是并没有。然后查看 k8s 文档，找到了这个参数：

```yaml

        securityContext:
          runAsUser: 0
```
这样可以使容器以 root 用户运行。0 指 root 用户的 uid。(生产环境需要指定用户启动，在构建竟像时候需要建一个用户，执行脚本切换到这个用户，比如建 hdfs 用户，修改这一行：`-streaming.driver.port 9003" | su hdfs | chown -R hdfs /opt/spark/work-dir  | bash)`

```yaml
# 把这个参数加上后：
apiVersion: apps/v1
kind: Deployment
metadata:
  name: spark-hello
  namespace: default
spec:
  selector:
    matchLabels:
      app: spark-hello
  strategy:
    rollingUpdate:
      maxUnavailable: 0
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: spark-hello
    spec:
      containers:
      - name: spark-hello     
        args:
          - >-
            echo "/opt/spark/bin/spark-submit --master k8s://https://172.16.2.62:6443
            --deploy-mode client
            --name spark-pi
            --class org.apache.spark.examples.SparkPi
            --conf spark.kubernetes.namespace=default
            --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark
            --conf spark.jars.ivy=/tmp/.ivy
            --conf spark.executor.instances=2
            --conf spark.kubernetes.container.image=172.16.2.66:5000/spark:v3.0
            --conf spark.driver.host=$POD_IP
            local:///opt/spark/examples/jars/spark-examples_2.12-3.0.2-SNAPSHOT.jar" | bash
        command:
          - /bin/sh
          - '-c'
        env:
          - name: POD_IP
            valueFrom:
              fieldRef:
                fieldPath: status.podIP          
        image: '172.16.2.66:5000/spark:v3.0'
        imagePullPolicy: Always
        securityContext:
          runAsUser: 0
kubectl delete deploy spark-hello
kubectl create -f spark-hello.yaml

 
# 继续报错：
Exception in thread "main" io.fabric8.kubernetes.client.KubernetesClientException: Failure executing: POST at: https://172.16.2.62:6443/api/v1/namespaces/default/pods. Message: Forbidden!Configured service account doesn't have access. Service account may have been revoked. pods is forbidden: User "system:serviceaccount:default:default" cannot create resource "pods" in API group "" in the namespace "default".
  at io.fabric8.kubernetes.client.dsl.base.OperationSupport.requestFailure(OperationSupport.java:568)
  at io.fabric8.kubernetes.client.dsl.base.OperationSupport.assertResponseCode(OperationSupport.java:505)
  at io.fabric8.kubernetes.client.dsl.base.OperationSupport.handleResponse(OperationSupport.java:471)
  at io.fabric8.kubernetes.client.dsl.base.OperationSupport.handleResponse(OperationSupport.java:430)
  at io.fabric8.kubernetes.client.dsl.base.OperationSupport.handleCreate(OperationSupport.java:251)
  at io.fabric8.kubernetes.client.dsl.base.BaseOperation.handleCreate(BaseOperation.java:815)
  at io.fabric8.kubernetes.client.dsl.base.BaseOperation.create(BaseOperation.java:333)
  at org.apache.spark.deploy.k8s.submit.Client.run(KubernetesClientApplication.scala:129)
  at org.apache.spark.deploy.k8s.submit.KubernetesClientApplication.$anonfun$run$3(KubernetesClientApplication.scala:235)
  at org.apache.spark.deploy.k8s.submit.KubernetesClientApplication.$anonfun$run$3$adapted(KubernetesClientApplication.scala:229)
  at org.apache.spark.util.Utils$.tryWithResource(Utils.scala:2539)
  at org.apache.spark.deploy.k8s.submit.KubernetesClientApplication.run(KubernetesClientApplication.scala:229)
  at org.apache.spark.deploy.k8s.submit.KubernetesClientApplication.start(KubernetesClientApplication.scala:202)
  at org.apache.spark.deploy.SparkSubmit.org$apache$spark$deploy$SparkSubmit$$runMain(SparkSubmit.scala:928)
  at org.apache.spark.deploy.SparkSubmit.doRunMain$1(SparkSubmit.scala:180)
  at org.apache.spark.deploy.SparkSubmit.submit(SparkSubmit.scala:203)
  at org.apache.spark.deploy.SparkSubmit.doSubmit(SparkSubmit.scala:90)
  at org.apache.spark.deploy.SparkSubmit$$anon$2.doSubmit(SparkSubmit.scala:1007)
  at org.apache.spark.deploy.SparkSubmit$.main(SparkSubmit.scala:1016)
  at org.apache.spark.deploy.SparkSubmit.main(SparkSubmit.scala)
 
``` 
spark submit 明明指定了  `spark.kubernetes.authenticate.driver.serviceAccountName`，为什么没有生效呢？

笔者这次没有浪费太多时间，肯定是 deployment 文件的问题，笔者就去 k8s 看 deployment  的文档，参数多的让人看着头疼，但最终还是找到了。

`serviceAccountName: spark`

完整的脚本：

```yaml
# 把这个参数加上后：
apiVersion: apps/v1
kind: Deployment
metadata:
  name: spark-hello
  namespace: default
spec:
  selector:
    matchLabels:
      app: spark-hello
  strategy:
    rollingUpdate:
      maxUnavailable: 0
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: spark-hello
    spec:
      serviceAccountName: spark
      containers:
      - name: spark-hello     
        args:
          - >-
            echo "/opt/spark/bin/spark-submit --master k8s://https://172.16.2.62:6443
            --deploy-mode client
            --name spark-pi
            --class org.apache.spark.examples.SparkPi
            --conf spark.kubernetes.namespace=default
            --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark
            --conf spark.jars.ivy=/tmp/.ivy
            --conf spark.executor.instances=2
            --conf spark.kubernetes.container.image=172.16.2.66:5000/spark:v3.0
            --conf spark.driver.host=$POD_IP
            local:///opt/spark/examples/jars/spark-examples_2.12-3.0.2-SNAPSHOT.jar" | bash
        command:
          - /bin/sh
          - '-c'
        env:
          - name: POD_IP
            valueFrom:
              fieldRef:
                fieldPath: status.podIP          
        image: '172.16.2.66:5000/spark:v3.0'
        imagePullPolicy: Always
        securityContext:
          runAsUser: 0
          
```

```shell
kubectl delete deploy spark-hello
kubectl create -f spark-hello.yaml
 
 
kubectl get pods
NAME                                       READY   STATUS    RESTARTS   AGE
spark-hello-69bdffdcbb-zhgf8               1/1     Running   1          29s
spark-pi-c103a7777beb81d2-exec-1           1/1     Running   0          8s
spark-pi-c103a7777beb81d2-exec-2           1/1     Running   0          8
 
 
 
 
kubectl logs spark-hello-69bdffdcbb-zhgf8
21/02/07 09:56:17 INFO DAGScheduler: Job 0 finished: reduce at SparkPi.scala:38, took 1.249581 s
Pi is roughly 3.143515717578588
21/02/07 09:56:17 INFO SparkUI: Stopped Spark web UI at http://10.244.0.72:4040
```
笔者用了一天的时间把这几种模式调通了，对于一个接触三天的 k8s 小白来说已经很满足了。最大的感触是，遇到问题要仔细分析，不断的提出可能的假设，然后去验证，因为很多问题网上是找不到答案的，只有提高自己的分析与处理问题的能力，才能应对更难的问题。


