# Byzer Binary Package

Byzer-lang is the execution engine of Byzer Notebook. The deployment method is described below.

### Prerequisites

JDK8 and Spark are required for Byzer-lang to start.

#### JDK8 installation

Go to [Oracle website](https://www.oracle.com/java/technologies/downloads/#java8) to download the latest version of JDK 8.

Execute the following commands to download and extract the JDK8 tar.gz, and set the JAVA_HOME environment variable.

```
cd <JDK_installation directory>
wget "https://repo.huaweicloud.com/java/jdk/8u151-b12/jdk-8u151-linux-x64.tar.gz"
tar -xf jdk-8u151-linux-x64.tar.gz
rm jdk-8u151-linux-x64.tar.gz
```

#### Spark installation

Byzer-lang supports two versions of Spark:

mlsql-engine_3.0-2.1.0 and byzer-lang_3.0-2.2.0: Spark-3.1.1-hadoop3.2

mlsql-engine_2.4-2.1.0 and byzer-lang_2.4-2.2.0: Spark-2.4.3-hadoop2.7

According to your version, download and unzip [Spark tgz](https://spark.apache.org/downloads.html). Then set the SPARK_HOME environment variable.

```
## Download the appropriate Spark version
wget https://archive.apache.org/dist/spark/spark-3.1.1/spark-3.1.1-bin-hadoop3.2.tgz
wget https://archive.apache.org/dist/spark/spark-2.4.3/spark-2.4.3-bin-hadoop2.7.tgz
```

Remove $SPARK_HOME/jars/velocity-1.5.jar because this jar conflicts with byzer-lang.

### Download Byzer-lang binary package

Go to [Byzer-lang download page](https://download.byzer.org/byzer/) and select the version subdirectory such as 2.2.0 to download. The rules of binary package names are as follows:

```
byzer-lang_<spark_major_version>-<byzer_lang_version>    
```
Above them, spark_major_version refers to 2.4 or 3.0. nightly-build is updated daily for you to experience the latest features.

### Source code compilation (optional)

If you want to compile manually, please follow the steps in [README.md](https://github.com/byzer-org/byzer-lang#building-a-distribution) to complete the compilation.

### Install byzer-lang
Unzip the downloaded or compiled binary package and set the MLSQL_HOME environment variable. JDK8 and Spark are required for byzer-lang to start.

### Detailed start-up parameters
A typical startup command:
```shell
$SPARK_HOME/bin/spark-submit --class streaming.core.StreamingApp \u
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
        u-streaming.spark.service true \
        -streaming.thrift false \
        -streaming.enableHiveSupport true
```

Dividing the above command into two parts, before **[1]** is Spark related configuration, and the latter part is Byzer-lang related configuration. There is another difference that Spark configuration starts with two dashes and Byzer-lang configuration starts with a dash.

In this way, we can run Byzer-lang on various environments such as K8s, Yarn, Mesos and Local.
> Note: Byzer-lang uses a lot of parameters starting with spark and they must be configured with --conf instead of -. 

**Common parameters**

| Parameter | Instruction | Example Value |
|----|----|-----|
| streaming.master | It is equivalent to --master, if you set it in spark, you don't need to set this in Byzer-lang. |     |
| streaming.name | application name |     |
| streaming.platform | platform | only spark |
| streaming.rest | whether to turn on the http interface | Boolean value and it needs to be set to true. |
| streaming.driver.port | HTTP service port | generally set to 9003 |
| streaming.spark.service | whether to exit the program after execution | true: do not exit, false: exit |
| streaming.job.cancel | supports running timeout settings | generally set to true |
| streaming.datalake.path | The data lake base directory is generally HDFS | It needs to be set, otherwise many functions will not be available such as plugins. |


### Local mode
$MLSQL_HOME/bin/start-local.sh contains Byzer-lang basic parameters, please refer to the above document to modify and start.

```shell
mkdir -p $MLSQL_HOME/logs
nohup $MLSQL_HOME/bin/start-local.sh > $MLSQL_HOME/logs/mlsql_engine.log 2>&1 &
```

### Yarn mode

We recommend starting byzer-lang in yarn-client mode. The yarn-cluster mode is started. Since AM is on a server in the Yarn cluster, the IP is not fixed, which will cause a series of problems.

1. Soft link `core-site.xml hdfs-site.xml yarn-site.xml` file to $SPARK_HOME/conf directory.
2. Set the environment variable `HADOOP_CONF_DIR`, pointing to $SPARK_HOME/conf . The reference command is as follows
```shell
export HADOOP_CONF_DIR=$SPARK_HOME/conf
```
3. Modify`start-local.sh` and find the following code snippet in the file

```shell
$SPARK_HOME/bin/spark-submit --class streaming.core.StreamingApp \u
        --driver-memory ${DRIVER_MEMORY} \
        --jars ${JARS} \
        --master local[*] \
        --name mlsql \
        --conf "spark.sql.hive.thriftServer.singleSession=true"
```

Replace the local[*] of `--master` with yarn, add `--deploy-mode client`, and then add the executor configuration, as shown below:

```shell
$SPARK_HOME/bin/spark-submit --class streaming.core.StreamingApp \u
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

Then run it.

### K8S mode
[K8S Image Deloyment Guidance](/byzer-lang/en-us/installation/containerized_deployment/K8S-deployment.md)

### Stop Byzer-lang
Execute $MLSQL_HOME/bin/stop-local.sh

### More parameters
[Byzer-lang parameters](/byzer-lang/en-us/installation/byzer-lang-configuration.md)
