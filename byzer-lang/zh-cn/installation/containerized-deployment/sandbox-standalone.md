# Sandbox 独立部署

Sandbox 镜像统一将 Byzer 引擎、Byzer Notebook 和 MySQL 打包到一个镜像中，用于快速的在本地体验 Byzer。

如果您需要将多个组件分开部署，可以使用  [Sandbox 多容器部署](/byzer-lang/zh-cn/installation/containerized-deployment/muti-continer.md) 方式。

### 前置条件

#### 安装 Docker Desktop

Docker 桌面版是一个适用于 MacOS 和 Windows 机器的应用程序，用于构建和共享容器化应用程序和微服务。它为用户提供了非常丰富便捷的管理平台，方便用户快速部署、管理 Sandbox 镜像和容器。

首先请从 [Docker 官网](https://www.docker.com/products/docker-desktop) 下载适配您操作系统的安装包，安装并使用。

适用于 Linux 的 Docker 桌面社区还在开发。若您需要在 Linux 上安装 Docker 引擎，请参考 [Docker 官网安装文档](https://docs.docker.com/engine/install/ubuntu/)。

### Sandbox 独立部署 Byzer

#### 下载 Byzer docker repo 最新的 image（基于 Spark 3）：

```shell
docker pull byzer/byzer-sandbox:3.1.1-latest
```
> 该版本为非稳定版本，包含最新研发但尚未 release 的特性。

#### Byzer on Spark3

使用 docker 命令启动 Spark 3.1.1 版 Sandbox 容器:

```shell
docker run -d \
-p 3306:3306 \
-p 9002:9002 \
-p 9003:9003 \
-e MYSQL_ROOT_HOST=% \
-e MYSQL_ROOT_PASSWORD=root \
--name sandbox-3.1.1-<Byzer Release 版本号> \
--restart=always \
byzer/byzer-sandbox:3.1.1-<Byzer Release 版本号>
```

> **注意：**
> `Byzer Release 版本号`请参考 Docker Hub 中  byzer-sandbox 的 Release Tags：https://hub.docker.com/r/byzer/byzer-sandbox/tags
> 参考 [Byzer 引擎部署指引](/byzer-lang/zh-cn/installation/README.md) 一节中
> docker 启动命令中映射了 MySQL 的端口号，如果本地安装了 MySQL 的话，可能会存在端口冲突，需要重新定义一个端口号，如：`-p 13306:3306`


#### Byzer on Spark2

如果需要体验 Spark2.4 版本的 Byzer， 下载 Byzer docker repo 中的稳定版本（基于 Spark 2）：

```shell
docker pull byzer/byzer-sandbox:2.4.3-<Byzer Release 版本号>
```

使用 docker 命令启动 Spark 2.4.3 版 Sandbox 容器:

```shell
docker run -d \
-p 3306:3306 \
-p 9002:9002 \
-p 9003:9003 \
--name sandbox-2.4.3-<Byzer Release 版本号> \
--restart=always \
-e MYSQL_ROOT_HOST=% \
-e MYSQL_ROOT_PASSWORD=root \
byzer/byzer-sandbox:2.4.3-<Byzer Release 版本号>
```


### 体验 Byzer 功能

Sandbox 启动需要一段时间，服务启动后会暴露两个端口：
- `9002`: Byzer Notebook 服务端口 
- `9003`: Byzer Engine 的服务端口


当 Sandbox 启动成功后，我们可以通过 `localhost:9002` 地址来访问 Byzer Notebook. 在用户登陆界面，输入用户名和密码: `admin/admin` 进入Byzer Notebook 首页。

<p align="center">
    <img src="/byzer-lang/zh-cn/installation/server/images/login.png" alt="name"  width="800"/>
</p>


点击 **创建新笔记本 - 创建** 并在弹窗中为笔记本起名，点击 **创建** 进入 Notebook 使用界面开始体验 Byzer 功能。

#### 使用 Python 和 Ray 处理 JSON 数据

在单元格中输入以下代码，并点击上方工具栏中的单箭头标志（**运行**）执行代码:

```sql
-- 构造测试数据
set mockData='''

{"title":"第一","body":"内容 1"}
{"title":"第二","body":"内容 2"}
{"title":"第三","body":"内容 3"}

''';

load jsonStr.`mockData` as data;

-- 设置 Python 环境 
!python env "PYTHON_ENV=:";
!python conf "runIn=driver";
!python conf "schema=st(field(title,string),field(body,string))";
!python conf "dataMode=data";

-- Python 代码在 Sandbox 内置的 Ray 上执行
!ray on data '''

import ray
from pyjava.api.mlsql import RayContext
import numpy as np;

ray_context = RayContext.connect(globals(),"localhost:10001")

def echo(row):
    row1 = {}
    row1["title"]="jackm"
    row1["body"]= row["body"]
    return row1

ray_context.foreach(echo)

''' named newdata;

select * from newdata as output;
```

结果如下:

  <img src="/byzer-lang/zh-cn/installation/containerized-deployment/images/python-ray-result.PNG" alt="Python-Ray 结果"/>

#### 处理 MySQL 数据

点击上方工具栏中的 **+** 新增单元格，并在单元格中输入以下代码，点击工具栏中的单箭头标志（**运行**）执行代码：

 ```sql
-- 加载 mlsql_console.mlsql_job 表数据
load jdbc.`usage_template` where url="jdbc:mysql://localhost:3306/notebook?characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&tinyInt1isBit=false"
 and driver="com.mysql.jdbc.Driver"
 and user="root"
 and password="root"
 as table1;
 
-- 查询100条
select * from table1 limit 10 as table2;

-- 保存到DeltaLake
save append table2 as delta.`dt1`;

-- 查询 DeltaLake 
load delta.`dt1` as table3;
 
select * from table3 as table4;
 ```

结果如下:

  <img src="/byzer-lang/zh-cn/installation/containerized-deployment/images/mysql-deltalake.PNG" alt="MySQL-deltalake"/>
