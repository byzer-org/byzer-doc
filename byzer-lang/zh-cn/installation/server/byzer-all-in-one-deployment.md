# Byzer All In One 安装与配置

Byzer All In One 版本除了提供 Byzer 引擎外，还**内置集成了如下组件**：
- Byzer CLI 命令行交互插件，源码 [byzer-org/byzer-cli](https://github.com/byzer-org/byzer-cli)
- JDK 1.8
- Spark 
- Byzer 插件集合，源码 [byzer-org/byzer-extension](https://github.com/byzer-org/byzer-cli) 


Byzer All In One 提供了两种交互的方式：
1. **命令行交互模式（CLI Mode）**：允许用户通过命令行的交互来执行 Byzer 脚本
2. **REST 服务交互模式（Server Mode）**: 允许用户通过 REST API 的方式调用 Byzer API 来执行 Byzer 脚本

> 注意：
> 1. 当前 Byzer 引擎支持的 Byzer 脚本的文件后缀名为 `.byzer` 和 `.mlsql`
> 2. Byzer All In One 的默认出场配置是以 Local 方式进行任务执行的

### 下载 Byzer All In One

请前往 [Byzer 官方下载站点](https://download.byzer.org/byzer/) 下载对应的 Byzer All In One 产品包。

#### 选择版本
如何选择对应的 Byzer 引擎版本说明，请参考 [Byzer 引擎部署指引](/byzer-lang/zh-cn/installation/README.md) 中 **Byzer 引擎版本说明** 一节，一般情况下，我们推荐使用最新的正式发布版本

#### 产品包名说明

- 在 Byzer `2.3.0` 版本以前，Byzer All In One 的包名规范为 `byzer-lang-{os}-{spark-vesion}-{byzer-version}.tar.gz`
- 在 Byzer `2.3.0` 及之后发布的版本，Byzer All In One 包名规范为 `byzer-all-in-one-{os}-{spark-vesion}-{byzer-version}.tar.gz`

其中 `｛os｝` 为对应的操作系统版本：
- **darwin-amd64**: macOS
- **win-amd64**: 64 位 windows 操作系统
- **linux-amd64**: 64 位 linux 操作系统

`｛spark-version｝` 是 Byzer 引擎内置的 Spark 版本，`{byzer-version}` 是 Byzer 的版本。


### 安装流程

这里我们以 Linux 环境和 Byzer `2.2.1` 版本举例说明， 访问 [https://download.byzer.org/byzer/2.2.1/](https://download.byzer.org/byzer/2.2.1/) ，下载 Byzer `2.2.1` 二进制包 `byzer-lang-linux-amd64-3.0-2.2.1.tar.gz` 

#### 解压安装包

此处我们以目录 `/home/byzer` 为例，下载安装包至此目录，解压安装包

```shell
$ tar -zxvf byzer-lang-linux-amd64-3.0-2.2.1.tar.gz 
$ cd byzer-lang-linux-amd64-3.0-2.2.1
```
此处我们解压后的目录为 `/home/byzer/byzer-lang-linux-amd64-3.0-2.2.1`，解压后的目录结构如下

```
|-- bin
|-- jdk8
|-- libs
|-- logs
|-- main
|-- plugin
|-- spark-warehouse
|-- test-scripts
`-- velocity.log
```


#### 设置 Java 环境
Byzer 引擎的执行需要 JDK 1.8，如果你的环境中已经配置好了 JDK1.8， 则可以跳过此步骤，你也可自行安装配置 JDK。

如果你的环境中没有 JDK，可以参考如下方式来使用 Byzer 内置的 JDK。

编辑 `~/.bash_profile`，加入下面的内容

```shell
export JAVA_HOME=/home/byzer/byzer-lang-linux-amd64-3.0-2.2.1/jdk8
export JRE_HOME=$JAVA_HOME/jre
export CLASSPATH=$JAVA_HOME/lib:$JRE_HOME/lib:$CLASSPATH
export PATH=$JAVA_HOME/bin:$JRE_HOME/bin:$PATH
```
执行 `source ~/.bash_profile` 使环境变量生效。

此时执行 `java -version` 命令，如果看到如下的输出说明 Java 配置成功

```shell
$ java -version
java version "1.8.0_151"
Java(TM) SE Runtime Environment (build 1.8.0_151-b12)
Java HotSpot(TM) 64-Bit Server VM (build 25.151-b12, mixed mode
```

### 通过命令行交互

Byzer All In one 提供了命令行的交互方式，交互命令位于安装目录下的 bin 目录中， 可执行文件为 `bin/byzer`

#### 将 Byzer All In One 安装目录加入环境变量

我们可以通过在 `~/.bash_profile` 中加入如下内容，您可以替换 `BYZER_HOME` 为实际安装目录

```shell
export BYZER_HOME=/home/byzer/byzer-lang-linux-amd64-3.0-2.2.1
export PATH=${BYZER_HOME}/bin:$PATH
```

上述环境变量是将 Byzer 安装目录下的 bin 目录添加至系统的 PATH 中，从而可以使得用户可以直接在 Terminal 中使用 `byzer` 命令。

添加完毕后，执行 `source ~/.bash_profile` 来使得环境变量生效

#### 验证安装是否成功

执行 `byzer -version`，当出现如下的输出时，说明安装成功

```shell
$ byzer -version
mlsql lang cli version 0.0.4-dev (2021-12-20 61a87d8)
```

#### 创建 Byzer 测试脚本

我们创建一个名为 `hello_byzer.byzer` 的 Byzer 测试脚本，在脚本中写入

```sql
load Everything.`` as table;
```
这条语句代表的是 Byzer 语言的设计理念，**Everything is a table**

执行后这个脚本，可以看到结果输出为

```shell
$ byzer run /home/byzer/hello_byzer.byzer
...
...
...
+----------+
|Hello     |
+----------+
|Byzer-lang|
+----------+

```
说明 Byzer All In One 在该 Linux 环境下安装成功。 Byzer CLI 的交互是一次性的，当执行完脚本后，进程就自动退出了。

### 启动 Byzer 服务

除了命令行的交互外， Byzer All In One 也可以启动服务，你可以执行 `bin/start-mlsql-app.sh` 脚本，来启动服务。

```shell
sh bin/start-mlsql-app.sh
```

等服务正常启动后，你可以在通过浏览器访问 `http://{host}:9003` 来访问到 Byzer Web Console，如下图所示

![](images/console.png)

点击运行可以查看到上述 SQL 执行的结果，说明服务正常启动。

> 注意:
> 1. `start-mlsql-app.sh` 脚本默认不是自动在后台执行的
> 2. 通过 `CTRL－Ｃ` 就可以停止当前 Byzer 服务

#### 后台运行 Byzer 引擎

如果您需要后台运行该引擎，你可以在 bin 目录下创建一个新的 shell 启动脚本 `start-byzer-lang-nohup.sh`，如下所示

```shell
#!/usr/bin/env bash

#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

base=$(cd "$(dirname $0)/.." && pwd)
cd "$base" || return

MAIN_JAR=$(ls ${base}/main | grep 'streamingpro-mlsql')
echo ${MAIN_JAR}

nohup ${base}/jdk8/bin/java -cp ${base}/main/${MAIN_JAR}:${base}/spark/*:${base}/libs/*:${base}/plugin/* \
tech.mlsql.example.app.LocalSparkServiceApp \
-streaming.plugin.clzznames tech.mlsql.plugins.assert.app.MLSQLAssert,tech.mlsql.plugins.ds.MLSQLExcelApp >> ${base}/logs/byzer-lang.out &
```

保存脚本并执行如下命令

```shell
$ sh ./bin/start-byzer-lang-nohup.sh
```

启动成功后，即可通过 `http://{host}:9003` 来进行访问。

如果需要停止后台执行的 Byzer lang 引擎，可以通过 `ps -ef | grep mlsql` 找到正在运行的进程，通过 `kill ${pid}` 的方式停止该进程即可
