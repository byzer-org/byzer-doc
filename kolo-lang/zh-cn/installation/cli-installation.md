# Kolo-lang 命令行安装与配置

我们提供了命令行执行脚本的能力，方便用户自助实现更多自动化能力，如下图所示，我们通过命令行执行一个开发好的 Kolo-lang 脚本：

![execute mlsql cli](images/execute-byzer-lang-cli.png)

### 安装流程

#### 一、设置 Kolo-lang 环境

下面将介绍 byzer-lang 命令行的几个环境变量的含义和安装步骤。

1. 环境变量的含义

使用前，需要设置两个环境变量：`MLSQL_LANG_HOME` 和 `PATH`。

- **MLSQL_LANG_HOME**：该环境变量的值就是 byzer-lang 命令行所在的目录，设置 `PATH` 的时候，也可以使用该变量以方便设置。

- **PATH**：指定一个路径列表，用于搜索可执行文件。执行一个可执行文件时，如果该文件不能在当前路径下找到，则会依次寻找 `PATH` 中的每一个路径，直至找到可执行文件为止。Kolo-lang 命令行的执行命令 (mlsql) 在其安装路径下的 bin 目录中。因此我们应该将该路径添加到 PATH 变量中。

2. 下载 byzer-lang 命令行

下载 mlsql 命令行程序包，地址如下：

- [mlsql lang mac](https://mlsql-downloads.kyligence.io/2.1.0/mlsql-app_2.4-2.1.0-darwin-amd64.tar.gz)

- [mlsql lang linux](https://mlsql-downloads.kyligence.io/2.1.0/mlsql-app_2.4-2.1.0-linux-amd64.tar.gz)


3. 目录结构

本示例以 mac 环境为例，下载 [适配 mac 环境的压缩包](https://mlsql-downloads.kyligence.io/2.1.0/mlsql-app_2.4-2.1.0-darwin-amd64.tar.gz) 后，对 tar 包进行解压缩，内部的目录结构如下：

```
├── mlsql-app_2.4-2.1.0-darwin-amd64
│        ├── bin
│        ├── libs
│        ├── main
│        ├── plugin
│        └── spark
```


4. 引入环境变量

接下来，需要把解压后的文件放置到固定的目录，并配置环境变量，其中 `MLSQL_LANG_HOME` 为包含 `bin` 目录的上一层目录，如下所示：

```
export MLSQL_LANG_HOME=/opt/mlsql-app_2.4-2.1.0-linux-amd64
export PATH=${MLSQL_LANG_HOME}/bin:$PATH
```

> **注意** ：该示例将程序包放在 /opt 目录下，用户可以指定其他方便使用的位置。


5. 查看使用手册

修改完环境变量后，可以通过 `version` 验证是否安装成功和当前 mlsql 命令行版本，具体命令如下：

```shell
mlsql --version
```

如果正常配置，将显示下面的日志：

```
mlsql lang cli version 0.0.4-dev (2021-09-06 4a628b2)
```



#### 二、执行 Kolo-lang 脚本

```shell
mlsql run ./src/common/hello.mlsql
```

### 使用示例

下面我们来看一个完整的例子，我们创建一个 `hello.mlsql` 的脚本文件，内容如下：

```
!hdfs -ls /;
```

使用一行命令，执行 Kolo-lang 脚本：

```shell
mlsql run hello.mlsql
```

注意，如果是 Mac 用户，会提示 App 的安全问题，如下图：

![无法打开MLSQL](images/mac_app_warn.png)

需要通过 系统偏好设置 - 安全性与隐私 - 允许从以下位置下载 App ，选择仍然允许。

![安全性与隐私](images/mac_app_warn_2.jpeg)

然后我们就可以通过命令行执行并查看效果，完整的执行日志如下：
```
(root) lin.zhang@Lin-ZhangdeMacBook-Pro admin % mlsql run hello.mlsql
2021/09/09 18:41:34.141238 mlsql[80463] <INFO>: [-cp /opt/mlsql-lang/main/*:/opt/mlsql-lang/libs/*:/opt/mlsql-lang/plugin/*:/opt/mlsql-lang/spark/* streaming.core.StreamingApp -streaming.master local[*] -streaming.name MLSQL-desktop -streaming.rest false -streaming.thrift false -streaming.platform spark -streaming.spark.service false -streaming.job.cancel true -streaming.datalake.path ./data/ -streaming.driver.port 9003 -streaming.plugin.clzznames tech.mlsql.plugins.ds.MLSQLExcelApp,tech.mlsql.plugins.shell.app.MLSQLShell,tech.mlsql.plugins.assert.app.MLSQLAssert -streaming.platform_hooks tech.mlsql.runtime.SparkSubmitMLSQLScriptRuntimeLifecycle -streaming.mlsql.script.path hello.mlsql -streaming.mlsql.script.owner admin -streaming.mlsql.sctipt.jobName mlsql-cli]
SLF4J: Class path contains multiple SLF4J bindings.
SLF4J: Found binding in [jar:file:/opt/mlsql-lang/main/streamingpro-mlsql-spark_2.4_2.11-2.1.0-SNAPSHOT.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: Found binding in [jar:file:/opt/mlsql-lang/spark/slf4j-log4j12-1.7.16.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: See http://www.slf4j.org/codes.html#multiple_bindings for an explanation.
SLF4J: Actual binding is of type [org.slf4j.impl.Log4jLoggerFactory]
log4j:WARN No such property [rollingPolicy] in org.apache.log4j.RollingFileAppender.
21/09/09 18:41:34  WARN Utils: Your hostname, Lin-ZhangdeMacBook-Pro.local resolves to a loopback address: 127.0.0.1; using 192.168.1.100 instead (on interface en0)
21/09/09 18:41:34  WARN Utils: Set SPARK_LOCAL_IP if you need to bind to another address
21/09/09 18:41:35  WARN NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
21/09/09 18:41:35  WARN Utils: Service 'SparkUI' could not bind on port 4040. Attempting port 4041.
21/09/09 18:41:38  INFO MLSQLStreamManager: Start streaming job monitor....
21/09/09 18:41:40  INFO SnapshotTimer: Scheduler MLSQL state every 3 seconds
21/09/09 18:41:42  INFO MLSQLExcelApp: Load ds: tech.mlsql.plugins.ds.MLSQLExcel
21/09/09 18:41:43  INFO JobManager: JobManager started with initialDelay=30 checkTimeInterval=5
21/09/09 18:41:43  INFO FileInputFormat: Total input paths to process : 1
21/09/09 18:41:43  INFO DefaultMLSQLJobProgressListener: [owner] [admin] [groupId] [8dab06e4-9195-4e0f-a2a2-ec4d22159a24] __MMMMMM__ Total jobs: 1 current job:1 job script:run command as HDFSCommand.`` where parameters='''["-ls","/tmp"]'''
+--------------------------------------------------------------------------------------------+
|fileSystem |
+--------------------------------------------------------------------------------------------+
|Found 20 items
-rw-r--r--   1 root      wheel         15 2021-09-06 13:35 /tmp/DidFinish.txt DidFinish.txt
|
+--------------------------------------------------------------------------------------------+

21/09/09 18:41:44  INFO JobManager: JobManager is shutdown....
```

> 恭喜，你已经完成 Kolo 命令行的安装和使用。