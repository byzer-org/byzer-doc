# Hive 数据源

Byzer 引擎默认提供了 Hive 读写的支持，可以和 Hive Metastore 进行交互，然后通过 Byzer 引擎可以直接处理 Hive 中表指向的 location
Byzer 支持通过 JDBC 来访问 Hive，但性能可能比较低下。

### 前置条件

1. Hive 实例（一般位于 Hadoop 集群上）
2. 根据 [Byzer Server 二进制版本安装和部署](/byzer-lang/zh-cn/installation/server/binary-installation.md) 在 Hadoop 集群的边缘节点（Edge Node）上安装 Byzer 引擎
3. 在 `$BYZER_HOME/conf/byzer.properties.override` 文件中，修改参数 `streaming.enableHiveSupport` 的值为 `true`

对 Hive 不同的版本，我们需要做的准备工作有些许差异

#### Hive 2.x

在 Hadoop 集群上启动 Byzer 引擎前需要确保 Spark 是可以连接到 Hive 的，那有两种方式
- 将 `hive-site.xml` 文件放入 Byzer 引擎使用的 `$SPARK_HOME` 中的 `conf` 目录下
- 如果您在启动 Byzer Engine 之前已参考 [Byzer Server 二进制版本安装和部署](/byzer-lang/zh-cn/installation/server/binary-installation.md) 执行了 `export HADOOP_CONF_DIR` 声明了环境变量，


通过 `$BYZER_HOME/byzer.sh start` 启动 Byzer 引擎即可。



#### Hive 3.x

如果您使用的环境是 Hive 3.x 版本：

1. 参考上文进行 `export HADOOP_CONF_DIR` 或将 `hive-site.xml` 放入至 `$SPARK_HOME/conf` 目录中


2. 收集 Hive 3.x 的 jar 包依赖，一般位于 Hive 的安装目录下，创建 `${BYZER_HOME}/dependencies/hive` 目录，将 Hive 3.x 的 Jar files 复制至该目录


3. 修改 `$SPARK_HOME/conf/spark-defaults.conf` 文件，如果该文件不存在，可以通过执行下述命令进行创建

```shell
$ cd ${SPARK_HOME}/conf
$ cp spark-defaults.conf.template spark-defaults.conf
```

我们以 `Hive 3.1.2` 版本为例，前往 [Apache Download Site](https://downloads.apache.org/hive/hive-3.1.2/) 下载 `apache-hive-3.1.2-bin.tar.gz`，解压后执行如下命令

```shell
$ cd apache-hive-3.1.2-bin
$ ls lib/ grep hive
```



在 `spark-defaults.conf` 文件中添加如下内容，注意替换 `$BYZER_HOME` 为绝对路径

```properties
spark.sql.hive.metastore.version=3.1.2
spark.sql.hive.metastore.jars=path
spark.sql.hive.metastore.jars.path=file:///${BYZER_HOME}/dependencies/hivehive-standalone-metastore-3.1.2.jar,file:///${BYZER_HOME}/dependencies/hivehive-exec-3.1.2.jar,file:///${BYZER_HOME}/dependencies/hivecommons-logging-1.0.4.jar,file:///${BYZER_HOME}/dependencies/hivecommons-io-2.4.jar,file:///${BYZER_HOME}/dependencies/hivejavax.servlet-api-3.1.0.jar,file:///${BYZER_HOME}/dependencies/hivecalcite-core-1.16.0.jar,file:///${BYZER_HOME}/dependencies/hivecommons-codec-1.7.jar,file:///${BYZER_HOME}/dependencies/hivelibfb303-0.9.3.jar,file:///${BYZER_HOME}/dependencies/hivemetrics-core-3.1.0.jar,file:///${BYZER_HOME}/dependencies/hivedatanucleus-core-4.1.17.jar,file:///${BYZER_HOME}/dependencies/hivedatanucleus-api-jdo-4.2.4.jar,file:///${BYZER_HOME}/dependencies/hivejavax.jdo-3.2.0-m3.jar,file:///${BYZER_HOME}/dependencies/hivedatanucleus-rdbms-4.1.19.jar,file:///${BYZER_HOME}/dependencies/hiveHikariCP-2.6.1.jar,file:///${BYZER_HOME}/dependencies/hivemysql-connector-java-5.1.48.jar,file:///work/spark/jars/commons-collections-3.2.2.jar,file:///${BYZER_HOME}/dependencies/hiveantlr-runtime-3.5.2.jar,file:///${BYZER_HOME}/dependencies/hivejackson-core-2.9.5.jar,file:///${BYZER_HOME}/dependencies/hivejackson-annotations-2.9.5.jar,file:///${BYZER_HOME}/dependencies/hivejackson-databind-2.9.5.jar,file:///${BYZER_HOME}/dependencies/hivejackson-mapper-asl-1.9.13.jar,file:///${BYZER_HOME}/dependencies/hivejackson-core-asl-1.9.13.jar
```


### 加载 Hive 数据源中的表

Hive 在 Byzer-lang 中使用极为简单。 加载 Hive 表只需要一句话：

```sql
load hive.`db1.table1`  as table1;
```

保存则是：

```sql
save overwrite table1 as hive.`db.table1`;
```

如果需要分区，则使用

```
save overwrite table1 as hive.`db.table1` partitionBy col1;
```

我们也可以使用 JDBC 访问 hive , 具体做法如下：

```sql
load jdbc.`db1.table1` 
where url="jdbc:hive2://127.0.0.1:10000"
and driver="org.apache.hadoop.hive.jdbc.HiveDriver"
and user="" 
and password="" 
and fetchsize="100";
```

说明:
- `jdbc:hive2://127.0.0.1:10000 ` 是 HiveServer2 地址
- HiveServer2 默认不需要用户名密码访问
- 请根据你的 Hive 版本, 将 jdbc jar 放到 Byzer-lang 安装目录的 libs 子目录.
- JDBC 查询性能不如原生方式查询。

我们也可以使用数据湖替换实际的 Hive 存储：

1. 启动时配置 `-streaming.datalake.path` 参数,启用数据湖。
2. 配置 `-spark.mlsql.datalake.overwrite.hive` Hive 采用数据湖存储。

使用时如下：

```sql
set rawText='''
{"id":9,"content":"Spark好的语言1","label":0.0}
{"id":10,"content":"MLSQL 是一个好的语言6","label":0.0}
{"id":12,"content":"MLSQL 是一个好的语言7","label":0.0}
''';

load jsonStr.`rawText` as orginal_text_corpus;

select cast(id as String)  as rowkey,content,label from orginal_text_corpus as orginal_text_corpus1;
save overwrite orginal_text_corpus1 as hive.`public.orginal_text_corpus1`;

load hive.`public.orginal_text_corpus1` as output ;
```

在你访问 Hive 时，如果数据湖里没有，则会穿透数据湖，返回 Hive 结果。如果你希望在写入的时候一定要写入到 Hive 而不是数据湖里，可以这样：

```
save overwrite orginal_text_corpus1 as hive.`public.orginal_text_corpus1` where storage="hive"; 
```

强制指定存储为 Hive.

### FAQ

#### 1. 如果我使用的 Byzer All In One，想要访问 Hive 需要怎么设置

如果您使用的 Byzer All-In-One，首先需要保证部署 Byzer All-In-One 的机器和 Hive Metastore 的网络是打通可访问的。

执行如下命令，将 `hive-site.xml` 打包成 `hive-conf.jar`

```shell
$ jar cvf hive-conf.jar hive-site.xml
```
将 `hive-conf.jar` 放入 Byzer All-In-One 安装目录下的 `spark` 目录中，即 `$BYZER_HOME/spark`

重启 Byzer 引擎即可。

> **注意**
> - 由于 All-In-One 中默认封装的 `$BYZER_HOME/spark` 目录中自带的依赖是 `Hive 2.3.7` 的，所以默认情况下只支持 Hive 2.x 系列
> - 如果您需要使用 All-In-One 来对接 Hive 3.x，您可以自行处理 `$BYZER_HOME/spark` 下的 Hive Jar 包依赖



#### 2. 如果我使用的 Byzer VSCode Extension，想要访问 Hive 需要怎么设置

如果您使用的 Byzer VSCode Extension，在 VSCode 的配置路径内（一般为 `~/.vscode/extensions/allwefantasy.mlsql-0.0.7/dist/mlsql-lang`），参考上一条，将打包好的 `hive-conf.jar` 放入至目录 `~/.vscode/extensions/allwefantasy.mlsql-0.0.7/dist/mlsql-lang/spark` 中，重启 VScode 即可