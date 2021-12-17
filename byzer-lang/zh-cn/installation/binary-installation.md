# Byzer-lang 安装与部署

Byzer-lang 是 Byzer Notebook 的执行引擎，下面介绍部署方式。

###  下载二进制包

[下载站点](https://download.byzer.org/byzer/) , 选择版本子目录例如 2.2.0 下载。二进制包名遵循以下规约

```
byzer-lang_<spark_major_version>-<byzer_lang_version>    
```
这里 spark_major_version 指 2.4 或者 3.0。SNAPSHOT 包每日更新，供您体验最新功能。byzer-lang 支持两个版本Spark

| Byzer-lang 版本          | Spark版本                  |
|------------------------|-----------------------|
| mlsql-engine_3.0-2.1.0 | Spark-3.1.1-hadoop3.2 |
| mlsql-engine_2.4-2.1.0 | Spark-2.4.3-hadoop2.7 | 
| byzer-lang_3.0-2.2.0   | Spark-3.1.1-hadoop3.2 |
| byzer-lang_2.4-2.2.0   | Spark-2.4.3-hadoop2.7 |

### 源码编译(可选)

若您想手动编译，请按照 [README.md](https://github.com/byzer-org/byzer-lang#building-a-distribution) 步骤即可完成编译。

### 安装 byzer-lang
下载或编译的二进制包解压，设置 MLSQL_HOME 环境变量。JDK8 和 Spark 是 byzer-lang 启动的必要条件。  

### JDK8 安装

执行以下命令下载并解压 JDK8 tar.gz，并设置 JAVA_HOME 环境变量

```shell
cd <JDK_安装目录>
wget "https://repo.huaweicloud.com/java/jdk/8u151-b12/jdk-8u151-linux-x64.tar.gz" 
tar -xf jdk-8u151-linux-x64.tar.gz  
rm jdk-8u151-linux-x64.tar.gz
```

### 安装 Spark

根据上面 Spark 兼容性表格，下载解压 Spark tgz，再设置 SPARK_HOME 环境变量
```shell
## 下载合适的 Spark 版本
wget https://archive.apache.org/dist/spark/spark-3.1.1/spark-3.1.1-bin-hadoop3.2.tgz
wget https://archive.apache.org/dist/spark/spark-2.4.3/spark-2.4.3-bin-hadoop2.7.tgz
```
删除 $SPARK_HOME/jars/velocity-1.5.jar，因为该 jar 与 byzer-lang 冲突. 

### 启动参数详解
一个典型的启动命令：
```shell
$SPARK_HOME/bin/spark-submit --class streaming.core.StreamingApp \
        --driver-memory ${DRIVER_MEMORY} \
        --jars ${JARS} \
        --master local[*] \
        --name mlsql \        
        --conf "spark.scheduler.mode=FAIR" \
       [1] ${MLSQL_HOME}/libs/${MAIN_JAR}    \ 
        -streaming.name mlsql    \
        -streaming.platform spark   \
        -streaming.rest true   \
        -streaming.driver.port 9003   \
        -streaming.spark.service true \
        -streaming.thrift false \
        -streaming.enableHiveSupport true
```

以位置[1]为分割点，前面主要是 Spark 相关配置，后面部分则是 Byzer-lang 相关配置。也有另外一个区别点，Spark 配置以两个横杠开头，
而 byzer-lang 配置以一个横杠开头。

通过在这种方式，我们可以将 Byzer-lang 运行在 K8s, Yarn, Mesos 以及 Local 等各种环境之上。
> Byzer-lang 使用到了很多以 spark 开头的参数，他们必须使用 --conf 来进行配置，而不是 - 配置。这个务必要注意。

**常用参数**

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
$MLSQL_HOME/bin/start-local.sh 包含 Byzer-lang 基本参数，请参考上面文档修改后启动。 

```shell
mkdir -p $MLSQL_HOME/logs
nohup $MLSQL_HOME/bin/start-local.sh > $MLSQL_HOME/logs/mlsql_engine.log 2>&1 &
```

### Yarn 模式启动

我们推荐使用 yarn-client 模式启动。

1. 将 hdfs/yarn/hive相关 xml 配置文件放到 $SPARK_HOME/conf 目录下。
2. 修改`start-local.sh`, 找到文件里如下代码片段

```shell
$SPARK_HOME/bin/spark-submit --class streaming.core.StreamingApp \
        --driver-memory ${DRIVER_MEMORY} \
        --jars ${JARS} \
        --master local[*] \
        --name mlsql \
        --conf "spark.sql.hive.thriftServer.singleSession=true" 
```

将--master的local[*] 换成 yarn-client, 然后添加 executor 配置, 大概如下面的样子：

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
        --conf "spark.sql.hive.thriftServer.singleSession=true" \
```

然后运行即可。


### K8S 模式启动
[K8S 模式启动](K8S-deployment.md)

### 停止 Byzer-lang
执行 $MLSQL_HOME/bin/stop-local.sh

### 更多参数
[Byzer-lang 更多参数](./byzer-lang-configuration.md)
