# Byzer Server 二进制版本安装和部署


区别于 Byzer All In One 版本的部署，Byzer Server 二进制包不包含如下的依赖：
- Byzer CLI
- JDK 1.8
- Spark 

Byzer Server 二进制包的安装需要用户自行下载部署 JDK 以及 Spark，并且只提供了 **REST 服务交互模式（Server Mode）** 来允许用户通过 REST API 的方式调用 Byzer API 来执行 Byzer 脚本。

> 1.**推荐在 Hadoop 集群上使用 Byzer 时，下载此版本进行安装**
> 2.如果您对 Linux Server 运维不熟悉，推荐使用 [Byzer All In One](/byzer-lang/zh-cn/installation/server/byzer-all-in-one-deployment.md) 进行部署
> 3. 推荐的操作系统为 CentOS7.x 以及 Ubuntu 18.04 +
> 4. **我们计划在 2.3.0 版本中, 重构 Byzer 引擎的部署方式来降低部署的复杂性**

### 下载 Byzer Server 二进制包

请前往 [Byzer 官方下载站点](https://download.byzer.org/byzer/) 下载对应的 Byzer Server二进制包。

#### 选择版本
如何选择对应的 Byzer 引擎版本说明，请参考 [Byzer 引擎部署指引](/byzer-lang/zh-cn/installation/README.md) 中 **Byzer 引擎版本说明** 一节，一般情况下，我们推荐使用最新的正式发布版本

#### 产品包名说明

Byzer Server二进制包的包名规范为 `byzer-lang_{spark-vesion}-{byzer-version}.tar.gz`

其中 `｛spark-version｝` 是 Byzer 引擎内置的 Spark 版本，`{byzer-version}` 是 Byzer 的版本。

> 注意：
> - 此处需要提前选择需要使用的 Spark 版本，Byzer 的版本要和 Spark 的版本一一对应
> - 当前支持的 Spark 版本为 `3.1.1` 以及` 2.3.3`


### 安装前置准备

JDK8 和 Spark 是 Byzer-lang 启动的必要条件。


#### JDK 1.8 安装

请根据自己系统的要求，下载并安装 JDK 1.8，并确保 `$JAVA_HOME` 被正确设置

#### Spark 安装

根据您下载的 Byzer 的版本，前往 [Spark Downloads](https://spark.apache.org/downloads.html) 下载对应的 Spark 版本，在指定位置解压后，需要在 `bash_profile` 中设置 `SPARK_HOME` 环境变量。

```
## 下载合适的 Spark 版本
$ wget https://archive.apache.org/dist/spark/spark-3.1.1/spark-3.1.1-bin-hadoop3.2.tgz
$ wget https://archive.apache.org/dist/spark/spark-2.4.3/spark-2.4.3-bin-hadoop2.7.tgz
```

> 注意：
> 1. 您需要删除 $SPARK_HOME/jars/velocity-1.5.jar，因为该 jar 与 byzer-lang 中的 Jar 冲突。
> 2. 如果您使用的是 Hadoop 发行版，则需要找到该 Hadoop 发行版提供的对应版本 Spark 进行安装



### 安装 Byzer 引擎

#### 解压安装并设置环境变量
1. 下载指定版本的 Byzer Server 二进制包，解压至指定位置
2. 设置环境变量 `$BYZER_HOME`
    - 通过 `export BYZER_HOME=/path/to/byzer-engine` 来设置临时环境变量
    - 或将上述环境变量加入至 `~/.bash_profile` 


#### 通过 Spark-Submit 命令启动 Byzer 引擎
Byzer 引擎本质就是一个 Spark Application， 可以通过 `spark-submit` 命令来启动。
在 `spark-submit` 命令中，可以通过 `--class ${class_name}` 来指定应用的入口类以及一系列的参数。

下面是一个典型的启动命令示例：

```shell
$SPARK_HOME/bin/spark-submit --class streaming.core.StreamingApp \
        --driver-memory ${DRIVER_MEMORY} \
        --jars ${JARS} \
        --master local[*] \
        --name mlsql \        
        --conf "spark.scheduler.mode=FAIR" \
       [1] ${BYZER_HOME}/libs/${MAIN_JAR}    \ 
        -streaming.name mlsql    \
        -streaming.platform spark   \
        -streaming.rest true   \
        -streaming.driver.port 9003   \
        -streaming.spark.service true \
        -streaming.thrift false \
        -streaming.enableHiveSupport true
```

**参数说明**:
- 以位置[1]为分割点，前面主要是 Spark 相关配置，后面部分则是 Byzer-lang 相关配置。
- Spark 的配置以两个横杠 `--conf` 开头，而 Byzer-lang 配置以一个横杠 `-` 开头。
- 对于 Byzer 引擎，Driver 内存一般推荐 8 GB 及以上

通过在这种方式，我们可以将 Byzer-lang 运行在 K8s, Yarn, Mesos 以及 Local 等各种环境之上。


#### 常用参数

| 参数 | 说明 | 示例值 |
|----|----|-----|
|  streaming.master  |  等价于--master 如果在spark里设置了，就不需要设置这个|     |
|  streaming.name  |  应用名称  |     |
|  streaming.platform  |  平台 |  目前只有spark   |
|  streaming.rest  |  是否开启http接口 |   布尔值，需要设置为true  |
|  streaming.driver.port | HTTP服务端口 |  一般设置为9003  |
|  streaming.spark.service  | 执行完是否退出程序 |  true 不退出  false 退出  |
|  streaming.job.cancel | 支持运行超时设置 |  一般设置为true  |
|  streaming.datalake.path | 数据湖基目录 一般为HDFS |  需要设置，否则很多功能会不可用，比如插件等。 |


### Local 模式启动

Local 模式启动，您可以执行 `$BYZER_HOME/bin/start-local.sh` 包含 Byzer-lang 基本参数，请参考上面文档修改后启动。 

```shell
mkdir -p $BYZER_HOME/logs
nohup $BYZER_HOME/bin/start-local.sh > $BYZER_HOME/logs/byzer_engine.log 2>&1 &
```

### Yarn 模式启动

我们推荐使用 yarn-client 模式启动。

> 因为当使用 yarn-cluster 模式启动时，由于 AM 在 Yarn 集群某台服务器，IP 可能会不固定，会造成一系列问题。

1. 软链接 `core-site.xml`, `hdfs-site.xml`, `yarn-site.xml` 文件到 `$SPARK_HOME/conf` 目录下。
2. 设置环境变量 `HADOOP_CONF_DIR`, 指向 `$SPARK_HOME/conf`, 参考命令如下

```shell 
export HADOOP_CONF_DIR=$SPARK_HOME/conf 
```
也可将此环境变量设置在 `~/.bash_profile` 文件中

3. 复制 `bin/start-local.sh` 为 `bin/start-on-yarn.sh`, 修改 `bin/start-on-yarn.sh`, 找到文件里如下代码片段

```shell
$SPARK_HOME/bin/spark-submit --class streaming.core.StreamingApp \
        --driver-memory ${DRIVER_MEMORY} \
        --jars ${JARS} \
        --master local[*] \
        --name mlsql \
        --conf "spark.sql.hive.thriftServer.singleSession=true" 
```

将 `--master` 的 `local[*]` 换成 `yarn`, 添加 `--deploy-mode client`, 然后添加 executor 配置, 大概如下面的样子：

```shell
$SPARK_HOME/bin/spark-submit --class streaming.core.StreamingApp \
        --driver-memory ${DRIVER_MEMORY} \
        --jars ${JARS} \
        --master yarn \
        --deploy-mode client \
        --executor-memory 2g \
        --executor-cores 1 \
        --num-executors 1 \
        --name mlsql \
        --conf "spark.sql.hive.thriftServer.singleSession=true" 
```

其中 Driver 和 Executor 的资源大小，根据实际情况来进行设置，然后执行 `bin/start-on-yarn.sh` 之后即可将 Byzer 引擎部署至 Yarn 上。

更多的配置信息请参考 [Byzer 引擎配置说明](/byzer-lang/zh-cn/installation/configuration/byzer-lang-configuration.md) 