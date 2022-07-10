# DolphinScheduler 1.3.9 安装配置指南

本章节将为您介绍 DolphinScheduler 1.3.9 单机部署和对接 Byzer Notebook 设置的详细过程，设定的安装目录为 `/opt/software/dolphinscheduler`，请预先执行命令创建好安装目录：

```bash
mkdir -p /opt/software/dolphinscheduler
```

### 前置条件

#### 1. 推荐的生产环境服务器配置

- CPU：4 核或以上

- 内存：8G 或以上

- 硬盘类型：SAS

- 网络：千兆网卡

#### 2. 推荐的操作系统

- Red Hat Enterprise 7.0 及以上

- CentOS 7.0 及以上

- Oracle Enterprise Linux 7.0 及以上

- Ubuntu 16.04 及以上

#### 3. 依赖环境安装

- [MySQL](https://dev.mysql.com/downloads/mysql/5.7.html) (5.7)：**需要 JDBC Driver 5.1.47+**

- [JDK](https://www.oracle.com/java/technologies/javase/javase8-archive-downloads.html) (1.8+)：必装，**推荐安装 jdk-8u161**，请安装好后在 `/etc/profile` 下配置 JAVA_HOME 及 PATH 变量

```shell
# 上传下载好的 jdk 包
# 解压缩，并重命名
tar -zxvf jdk-8u161-linux-x64.tar.gz -C /opt/software
mv /opt/software/jdk-8u161-linux-x64 /opt/software/jdk8

# vi 编辑 /etc/profile，追加两行并保存退出
export JAVA_HOME=/opt/software/jdk8
export PATH="$JAVA_HOME/bin:$PATH"

source /etc/profile
```

- [ZooKeeper](https://zookeeper.apache.org/releases.html) (3.4.6+)：必装

```shell
# 下载 zookeeper 安装包，也可以外部下载后上传到部署环境中
wget https://dlcdn.apache.org/zookeeper/zookeeper-3.6.3/apache-zookeeper-3.6.3-bin.tar.gz

# 解压缩，并重命名
tar -zxvf apache-zookeeper-3.6.3-bin.tar.gz -C /opt/software
mv /opt/software/apache-zookeeper-3.6.3-bin /opt/software/zookeeper

# 进入 zookeeper 目录
cd /opt/software/zookeeper
# 创建 data 目录
mkdir data

# 复制配置文件
cp conf/zoo_sample.cfg conf/zoo.cfg

# vi 修改 conf/zoo.cfg 中的 dataDir 项，并保存
dataDir=../data

# 启动 zookeeper，端口为 2181
./bin/zkServer.sh start
```

### DolphinScheduler 单机部署安装

#### 1. 下载并解压安装包

创建部署目录 `/opt/dolphinscheduler`（**注意：这里的部署目录不同于开头提到的安装目录**），下载 [DolphinScheduler 1.3.9](https://dlcdn.apache.org/dolphinscheduler/1.3.9/apache-dolphinscheduler-1.3.9-bin.tar.gz) 二进制包，并解压重命名为 `dolphinscheduler-1.3.9-bin`：

```shell
# 创建部署目录，部署目录请不要创建在 /root、/home 等高权限目录 
mkdir -p /opt/dolphinscheduler
cd /opt/dolphinscheduler

# 下载 dolphinscheduler 安装包和 MySQL JDBC 驱动，也可以外部下载后上传到部署环境中
wget https://dlcdn.apache.org/dolphinscheduler/1.3.9/apache-dolphinscheduler-1.3.9-bin.tar.gz
wget https://downloads.mysql.com/archives/get/p/3/file/mysql-connector-java-5.1.47.tar.gz

# 解压缩
tar -zxvf apache-dolphinscheduler-1.3.9-bin.tar.gz
mv apache-dolphinscheduler-1.3.9-bin  dolphinscheduler-1.3.9-bin

# 解压缩并复制 mysql-connector-java-5.1.47.jar 到 dolphinscheduler-1.3.9-bin/lib
tar -zxvf mysql-connector-java-5.1.47.tar.gz
cp mysql-connector-java-5.1.47/mysql-connector-java-5.1.47.jar dolphinscheduler-1.3.9-bin/lib/

# 可以清理除 dolphinscheduler-1.3.9-bin 外，不需要的下载及解压缩文件
```

#### 2. 创建部署用户

生产环境不建议直接使用 root 账号启动服务，为此需要创建部署用户 byzer，并配置 sudo 免密：

```shell
# 创建用户需使用 root 登录
useradd byzer

# 为 byzer 创建 home 目录
mkdir /home/byzer
chown -R byzer:byzer /home/byzer

# 添加密码
passwd byzer

# 配置 sudo 免密
sed -i '$abyzer  ALL=(ALL)  NOPASSWD: NOPASSWD: ALL' /etc/sudoers
sed -i 's/Defaults    requirett/#Defaults    requirett/g' /etc/sudoers

# 修改目录权限，使得部署用户对 dolphinscheduler-1.3.9-bin 目录有操作权限
chown -R byzer:byzer dolphinscheduler-1.3.9-bin

# 同时也授予该用户对安装目录 /opt/software/dolphinscheduler 目录的权限
chown -R byzer:byzer /opt/software/dolphinscheduler
```

此外，还需要为 byzer 用户配置 ssh 免密登录以满足 DolphinScheduler 执行任务时的需求：

```shell
# 使用 byzer 账号 ssh 登录至部署服务器
ssh byzer@{server-ip}

# 不需要输入密码表示成功，则免密 sudo 生效
sudo ls

ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# 验证 ssh 免密登录是否生效
ssh localhost
```

#### 3. 数据库初始化

进入数据库命令行窗口，执行数据库初始化命令，设置访问账号和密码，注意这里的` {user}` 和 `{password}` 需要替换为实际使用的数据库账号密码：

```sql
CREATE DATABASE dolphinscheduler DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT ALL PRIVILEGES ON dolphinscheduler.* TO '{user}'@'%' IDENTIFIED BY '{password}';
GRANT ALL PRIVILEGES ON dolphinscheduler.* TO '{user}'@'localhost' IDENTIFIED BY '{password}';
flush privileges;
```

接着修改 `/opt/dolphinscheduler/dolphinscheduler-1.3.9-bin/conf` 目录下的配置文件：

```shell
# 进入 dolphinscheduler 部署目录
cd /opt/dolphinscheduler/dolphinscheduler-1.3.9-bin
vi conf/datasource.properties

# 修改 datasource configuration
spring.datasource.driver-class-name=com.mysql.jdbc.Driver
spring.datasource.url=jdbc:mysql://{ip}:{port}/dolphinscheduler?useUnicode=true&characterEncoding=UTF-8&allowMultiQueries=true                          # 需要修改 {ip} 和 {port}
spring.datasource.username=xxx                    # 需要修改为上面的{user}值
spring.datasource.password=xxx                    # 需要修改为上面的{password}值
```

接着执行元数据初始化脚本，执行成功则表示以上安装过程没有问题：

```shell
sh script/create-dolphinscheduler.sh
```

### 4. 修改运行参数

修改 `conf/env` 目录下的 `dolphinscheduler_env.sh` 中的环境变量，此处只需要配置 `JAVA_HOME` 和 `PATH`，其他项可忽略：

```shell
export HADOOP_HOME=/opt/soft/hadoop                   # 忽略
export HADOOP_CONF_DIR=/opt/soft/hadoop/etc/hadoop    # 忽略
export SPARK_HOME1=/opt/soft/spark1                   # 忽略
export SPARK_HOME2=/opt/soft/spark2                   # 忽略
export PYTHON_HOME=/opt/soft/python                   # 忽略
export JAVA_HOME= /opt/software/jdk8                  # 修改为 Java 安装目录的绝对路径
export HIVE_HOME=/opt/soft/hive                       # 忽略
export FLINK_HOME=/opt/soft/flink                     # 忽略
export DATAX_HOME=/opt/soft/datax                     # 忽略

export PATH=$HADOOP_HOME/bin:$SPARK_HOME1/bin:$SPARK_HOME2/bin:$PYTHON_HOME:$JAVA_HOME/bin:$HIVE_HOME/bin:$FLINK_HOME/bin:$DATAX_HOME/bin:$PATH     # 不用改动
```

接着将 jdk 软链接到 `/usr/bin/java`：

```shell
sudo ln -s /opt/software/jdk8/bin/java /usr/bin/java
```

修改一键部署配置文件 `conf/config/install_config.conf` 中的各参数，特别注意以下参数的配置，其中 `resourceStorageType、singleYarnIp、hdfsRootUser、yarnHaIps`  项可按需配置：

```properties
# 这里填 mysql
dbtype="mysql"

# 数据库连接地址，{ip}、{port} 填入数据库的具体 ip 和 端口
dbhost="{ip}:{port}"

# 数据库名
dbname="dolphinscheduler"

# 数据库用户名，此处需要修改为上面设置的 {user} 具体值
username="{user}"    

# 数据库密码，如果有特殊字符，请使用 \ 转义，需要修改为上面设置的 {password} 具体值
password="{password}"

# Zookeeper地址，单机本机是 localhost:2181，记得把 2181 端口带上
zkQuorum="localhost:2181"

# 将 DS 安装到哪个目录，如: /opt/software/dolphinscheduler，不同于现在的目录
installPath="/opt/software/dolphinscheduler"

# 使用哪个用户部署，使用第 3 节创建的用户
deployUser="byzer"

# 邮件配置，以 qq 邮箱为例
# 邮件协议
mailProtocol="SMTP"

# 邮件服务地址
mailServerHost="smtp.qq.com"

# 邮件服务端口
mailServerPort="25"

# mailSender 和 mailUser 配置成一样即可
# 发送者
mailSender="xxx@qq.com"

# 发送用户
mailUser="xxx@qq.com"

# 邮箱密码
mailPassword="xxx"

# TLS 协议的邮箱设置为 true，否则设置为 false
starttlsEnable="true"

# 开启 SSL 协议的邮箱配置为 true，否则为 false。注意: starttlsEnable 和 sslEnable 不能同时为 true
sslEnable="false"

# 邮件服务地址值，参考上面 mailServerHost
sslTrust="smtp.qq.com"

# 业务用到的比如 sql 等资源文件上传到哪里，可以设置：HDFS,S3,NONE，单机如果想使用本地文件系统，请配置为 HDFS，因为 HDFS 支持本地文件系统；如果不需要资源上传功能请选择 NONE。强调一点：使用本地文件系统不需要部署 hadoop
resourceStorageType="HDFS"

# 这里以保存到本地文件系统为例
defaultFS="file:///data/dolphinscheduler"    #hdfs://{具体的ip/主机名}:8020

# 如果没有使用到 Yarn，保持以下默认值即可；如果 ResourceManager 是 HA，则配置为 ResourceManager 节点的主备 ip 或者 hostname，比如 "192.168.xx.xx,192.168.xx.xx" ;如果是单 ResourceManager 请配置 yarnHaIps="" 即可
# 注：依赖于yarn执行的任务，为了保证执行结果判断成功，需要确保yarn信息配置正确
yarnHaIps="192.168.xx.xx,192.168.xx.xx"

# 如果 ResourceManager 是 HA 或者没有使用到 Yarn 保持默认值即可；如果是单 ResourceManager，请配置真实的 ResourceManager 主机名或者 ip
singleYarnIp="yarnIp1"

# 资源上传根路径，支持 HDFS 和 S3，由于 hdfs 支持本地文件系统，需要确保本地文件夹存在且有读写权限
resourceUploadPath="/data/dolphinscheduler"

# 具备权限创建 resourceUploadPath 的用户
hdfsRootUser="hdfs"

# 配置 api server port
apiServerPort="12345"

# 在哪些机器上部署 DS 服务，本机选 localhost
ips="localhost"

# ssh 端口，默认22
sshPort="22"

# master 服务部署在哪台机器上
masters="localhost"

# worker 服务部署在哪台机器上，并指定此 worker 属于哪一个 worker 组，下面示例的 default 即为组名
workers="localhost:default"

# 报警服务部署在哪台机器上
alertServer="localhost"

# 后端 api 服务部署在在哪台机器上
apiServers="localhost"
```

注意：配置中用到了 `/data/dolphinscheduler` 目录作为 DolphinScheduler 的资源中心 ，请执行以下命令创建该目录：

```bash
sudo mkdir /data/dolphinscheduler

# 授予部署用户权限
sudo chown -R byzer:byzer /data/dolphinscheduler
```

#### 5. 一键部署

切换到部署用户 `byzer` ，执行一键部署脚本：

```shell
sh install.sh
```

> 注意： Ubuntu 系统执行此脚本需要把默认的 dash shell 切换成 bash shell，执行:
>
> ```shell
> # 执行后弹窗选择否，如需恢复，再次执行选择是
> sudo dpkg-reconfigure dash
> ```

启动成功后，可以使用 `jps` 命令查看服务是否启动，如果以下五个服务都正常启动，说明部署成功：

```
MasterServer               # master 服务
WorkerServer               # worker 服务
LoggerServer               # logger 服务
ApiApplicationServer       # api 服务
AlertServer                # alert 服务
```

可以访问前端页面地址：http://localhost:12345/dolphinscheduler （ip 地址需要根据服务器实际地址填写）

<p align="center">
    <img src="/byzer-notebook/zh-cn/schedule/images/ds_login.png" alt="Login DolphinScheduler"/>
</p>

#### 6. 服务启停

进入 `/opt/software/dolphinscheduler` 目录

```shell
# 一键停止
sh ./bin/stop-all.sh

# 一键启动
sh ./bin/start-all.sh
```

### 对接 Byzer Notebook

Byzer Notebook 需要访问 DolphinScheduler 的 API 接口管理调度任务，为此需要在 DolphinScheduler 端创建一个专供 Byzer Notebook 使用的用户账号，并为此用户账号配置租户和 API 鉴权 Token。

#### 1. 创建租户

使用 `admin` 账号登录 DolphinScheduler 前端页面（默认密码为 `dolphinscheduler123`），依次点击**安全中心—租户管理—创建租户**，**租户编码**和**租户名称**填入安装时创建的部署用户 `byzer`，提交保存：

<p align="center">
    <img src="/byzer-notebook/zh-cn/schedule/images/add_tenant.png" alt="Add Tenant"/>
</p>

#### 2. 创建用户

依次点击**安全中心—用户管理—创建用户**，**用户名**输入 `ByzerRobot`，**租户**选择刚刚创建的 `byzer` 租户，输入密码和邮箱，**提交**保存。

<p align="center">
    <img src="/byzer-notebook/zh-cn/schedule/images/add_user.png"/>
</p>

#### 3. 创建 AuthToken

使用刚刚创建的 ByzerRobot 账号重新登录 DolphinScheduler 页面，依次点击**右上角用户图标—用户信息—令牌管理—创建令牌**，**失效时间**可以酌情设置，点击**生成令牌**，然后**提交**保存：

<p align="center">
    <img src="/byzer-notebook/zh-cn/schedule/images/create_token.png" alt=""/>
</p>

<p align="center">
    <img src="/byzer-notebook/zh-cn/schedule/images/token_info.png" alt=""/>
</p>

#### 4. 创建项目

使用 ByzerRobot 账号登录 DolphinScheduler 页面，依次点击**项目管理—创建项目**，项目名称输入 `ByzerScheduler`（此名称是 Byzer Notebook 默认的项目名称），提交保存：

<p align="center">
    <img src="/byzer-notebook/zh-cn/schedule/images/add_tenant.png" alt="Add Tenant"/>
</p>

#### 5. 创建调度并验证

进入**项目管理**页面，依次点击 **ByzerScheduler—工作流定义—创建工作流**，拖拽工具栏侧的 **HTTP 图标**至其右侧画布，创建测试节点 test，请求地址填写 Byzer Notebook 的 `APIVersion` 接口：http://localhost:9002/api/version （ip 地址需根据 Byzer Notebook 所在服务器调整），点击**确认添加—右上角保存**：

<p align="center">
    <img src="/byzer-notebook/zh-cn/schedule/images/create_test_run.png" alt="name"/>
</p>



名称栏填入名称 testByzerNotebook，点击添加保存：

<p align="center">
    <img src="/byzer-notebook/zh-cn/schedule/images/add_test_run.png" alt="name"/>
</p>

在**工作流定义**页面点击操作栏第四个图标**上线，**接着点击第二个图标**运行，**弹窗后继续点击**运行**：

<p align="center">
    <img src="/byzer-notebook/zh-cn/schedule/images/test_run_online.png" alt="name"/>
</p>

<p align="center">
    <img src="/byzer-notebook/zh-cn/schedule/images/test_run.png" alt="name"/>
</p>

进入**工作流实例**页面等待一段时间后，查看最终的执行状态：

<p align="center">
    <img src="/byzer-notebook/zh-cn/schedule/images/test_run_result.png" alt="name"/>
</p>

**注意**：如果这里执行失败，需要检查Byzer Notebook 服务是否还存活。如果 DolphinScheduler 和 Byzer Notebook 分别部署在两台服务器上，需要排查两台服务器间网络连通性。

### 配置 Byzer Notebook

至此 DolphinScheduler 端的配置已完成，您只需把 DolphinScheduler 的 API 地址和前文生成的 AuthToken 填入 Byzer Notebook 配置文件中重启服务即可在 Byzer Notebook 中体验定时调度功能。

```properties
notebook.scheduler.enable=true
notebook.scheduler.scheduler-name=DolphinScheduler
notebook.scheduler.scheduler-url=http://localhost:12345/dolphinscheduler
notebook.scheduler.auth-token=c8887b34b10e407fa3ffef97ed5b27d1
```
