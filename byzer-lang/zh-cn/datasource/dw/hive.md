# Hive 数据源

Byzer 引擎默认提供了 Hive 读写的支持，可以和 Hive Metastore 进行交互，然后通过 Byzer 引擎可以直接处理 Hive 中表指向的 location 的数据文件

用户也可以通过 Hive 暴露的 JDBC 接口来访问 Hive，可以参考 [JDBC 数据源](/byzer-lang/zh-cn/datasource/jdbc/jdbc.md), 但性能相较于直接和 Hive Metastore 可能比较低下。

### 1. 前置条件

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


2. 收集 Hive 3.x 中和 Hive MetaStore 相关的 jar 包依赖，一般位于 Hive 的安装目录的 `lib` 目录下，创建 `${BYZER_HOME}/dependencies/hive/` 目录，将 Hive 3.x 的 MetaStore Jar files 复制至该目录


3. 修改 `$SPARK_HOME/conf/spark-defaults.conf` 文件，如果该文件不存在，可以通过执行下述命令进行创建

```shell
$ cd ${SPARK_HOME}/conf
$ cp spark-defaults.conf.template spark-defaults.conf
```

我们以 `Hive 3.1.2` 版本为例，前往 [Apache Download Site](https://downloads.apache.org/hive/hive-3.1.2/) 下载 `apache-hive-3.1.2-bin.tar.gz`，解压后执行如下命令

```shell
$ cd apache-hive-3.1.2-bin
$ ls lib
```
从输出中我们可以看到 hive 所有的依赖，找到 Hive Metastore 相关的依赖

```shell
- hive-standalone-metastore-3.1.2.jar
- hive-exec-3.1.2.jar

# libfb jars
- libfb303-0.9.3.jar

# metrics core jar
- metrics-core-3.1.0.jar

# javax jars
- javax.servlet-api-3.1.0.jar
- javax.jdo-3.2.0-m3.jar

# commons jars
- commons-logging-1.0.4.jar
- commons-io-2.4.jar
- commons-codec-1.7.jar
- commons-collections-3.2.2.jar

# calcite jars
- calcite-core-1.16.0.jar

# datanucleus jars
- datanucleus-core-4.1.17.jar
- datanucleus-api-jdo-4.2.4.jar
- datanucleus-rdbms-4.1.19.jar

# HikariCP jars
- HikariCP-2.6.1.jar

# antlr jars
- antlr-runtime-3.5.2.jar

# jackson jars
- jackson-core-2.9.5.jar
- jackson-annotations-2.9.5.jar
- jackson-databind-2.9.5.jar
- jackson-mapper-asl-1.9.13.jar
- jackson-core-asl-1.9.13.jar

# mysql connector driver
# please note this driver is not included in ${HIVE_HOME}/lib
- mysql-connector-java-5.1.48.jar
```

在 `spark-defaults.conf` 文件中添加如下内容，注意替换 `$BYZER_HOME` 为绝对路径
> 参考 Spark 官方文档 [Hive Tables](https://spark.apache.org/docs/latest/sql-data-sources-hive-tables.html)

```properties
spark.sql.hive.metastore.version=3.1.2
spark.sql.hive.metastore.jars=path
spark.sql.hive.metastore.jars.path=file:///${BYZER_HOME}/dependencies/hive/hive-standalone-metastore-3.1.2.jar,file:///${BYZER_HOME}/dependencies/hive/hive-exec-3.1.2.jar,file:///${BYZER_HOME}/dependencies/hive/commons-logging-1.0.4.jar,file:///${BYZER_HOME}/dependencies/hive/commons-io-2.4.jar,file:///${BYZER_HOME}/dependencies/hive/javax.servlet-api-3.1.0.jar,file:///${BYZER_HOME}/dependencies/hive/calcite-core-1.16.0.jar,file:///${BYZER_HOME}/dependencies/hive/commons-codec-1.7.jar,file:///${BYZER_HOME}/dependencies/hive/libfb303-0.9.3.jar,file:///${BYZER_HOME}/dependencies/hive/metrics-core-3.1.0.jar,file:///${BYZER_HOME}/dependencies/hive/datanucleus-core-4.1.17.jar,file:///${BYZER_HOME}/dependencies/hive/datanucleus-api-jdo-4.2.4.jar,file:///${BYZER_HOME}/dependencies/hive/javax.jdo-3.2.0-m3.jar,file:///${BYZER_HOME}/dependencies/hive/datanucleus-rdbms-4.1.19.jar,file:///${BYZER_HOME}/dependencies/hive/HikariCP-2.6.1.jar,file:///${BYZER_HOME}/dependencies/hive/mysql-connector-java-5.1.48.jar,file:///work/spark/jars/commons-collections-3.2.2.jar,file:///${BYZER_HOME}/dependencies/hive/antlr-runtime-3.5.2.jar,file:///${BYZER_HOME}/dependencies/hive/jackson-core-2.9.5.jar,file:///${BYZER_HOME}/dependencies/hive/jackson-annotations-2.9.5.jar,file:///${BYZER_HOME}/dependencies/hive/jackson-databind-2.9.5.jar,file:///${BYZER_HOME}/dependencies/hive/jackson-mapper-asl-1.9.13.jar,file:///${BYZER_HOME}/dependencies/hive/jackson-core-asl-1.9.13.jar
```

至此，通过 `${BYZER_HOME}/bin/byzer.sh start` 启动

### 2. 加载 Hive 数据源中的表

当按照上述前置条件配置好 Hive 的连接并启动 Byzer 引擎后，就可以通过 Byzer 语法进行 Hive 数据表的加载了。

Hive 作为 Byzer 支持的内置数据源之一，也可以通过 [LOAD 语法](/byzer-lang/zh-cn/grammar/load.md) 进行库和表的加载。

如下示例，Hive 表中有 Database `demo_db`，该 DB 下有表 `demo_table`，那么我们可以通过下述语句进行表 


#### 使用 Hive 关键字进行表的加载


```sql
> LOAD hive.`demo_db.demo_table`  as table1;
```
通过该语句，我们就可以将 Hive 中的 `demo_db.demo_table` 加载至 byzer 中，并命名为 `table1`，接下来就可以使用 select 对 `table1` 语句进行处理了。


在 LOAD hive 表的过程中，我们可以使用 `where` 语句来进行表的过滤


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
- 请根据你的 Hive 版本, 将 jdbc jar 放到 `$BYZER_HOME/libs` 目录下
- JDBC 查询性能不如原生方式查询。



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



#### 2. 如果我使用的 Byzer VSCode Extension，想要访问 Hive 需要怎么设置？

如果您使用的 Byzer VSCode Extension，在 VSCode 的配置路径内（一般为 `~/.vscode/extensions/allwefantasy.mlsql-0.0.7/dist/mlsql-lang`），参考上一条，将打包好的 `hive-conf.jar` 放入至目录 `~/.vscode/extensions/allwefantasy.mlsql-0.0.7/dist/mlsql-lang/spark` 中，重启 VScode 即可

#### 3. 是否可以对接其他的数仓？
如果您使用的数仓的 Catalog 组件是 Hive 兼容的，一般服务厂商会提供 sdk jar 包以及相应的配置文件，比如 AWS Glue，您可以参照 Hive 的配置方式进行配置即可。配置好后，我们就可以参考上述的 `LOAD` 语法对 Catalog 中的表进行读取。