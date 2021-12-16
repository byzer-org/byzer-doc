# 快速开始

本章节将会介绍如何使用 Docker 镜像环境快速体验 Kolo 的 IDE 应用平台 Byzer Notebook。

### 前置条件

[安装 Docker](!https://www.docker.com/products/docker-desktop)，如果已安装请忽略。

### 安装 Sandbox 镜像

1. 获取镜像

   `docker pull allwefantasy/mlsql-sandbox:<tag>`

   > tag 对应着镜像的版本号，[这里](!https://hub.docker.com/r/allwefantasy/mlsql-sandbox/tags)可以查看所有可用的 tag

2. 运行容器

   `docker run -d --name <container_name> -p <host_notebook__port>:9002 -p <host_kolo_port>:9003 -p <host_mysql_port>:3306 -e MYSQL_ROOT_PASSWORD=<mysql_pwd> allwefantasy/mlsql-sandbox:<tag>`

   > container_name 是运行的容器名称
   > host_notebook_port 是 notebook 服务在宿主机上暴露的端口
   > host_kolo_port 是 kolo 服务在宿主机上暴露的端口
   > host_mysql_port 是 mysql 服务在宿主机上暴露的端口
   > mysql_pwd 是 mysql 服务的 root 用户密码
   > tag 是上一步骤选定的镜像版本号

3. 浏览器访问

   访问 `http://localhost:9002` 即可开始体验 Byzer Notebook 了。

   初始管理员账号密码为 admin/admin。

### 安装示例

接下来，我们将通过示例来展示整个快速安装的过程。示例中命令行参数值分别如下：

- tag: 3.1.1-2.2.0
- container_name: byzer-sandbox
- host_notebook_port: 9002
- host_kolo_port: 9003
- host_mysql_port: 3306
- mysql_pwd: root

1. 获取镜像

   `docker pull allwefantasy/mlsql-sandbox:3.1.1-2.2.0`

   <img src="/kolo-lang/zh-cn/introduction/images/fetch_sandbox_image.png" alt="fetch_image"/>

2. 运行容器

   `docker run -d --name byzer-sandbox -p 9002:9002 -p 9003:9003 -p 3306:3306 -e MYSQL_ROOT_PASSWORD=root allwefantasy/mlsql-sandbox:3.1.1-2.2.0`

   <img src="/kolo-lang/zh-cn/introduction/images/run_sandbox_container.png" alt="run_container"/>

3. 浏览器访问

   访问 `http://localhost:9002`


   <img src="/kolo-lang/zh-cn/introduction/images/visit_notebook.png" alt="visit_notebook"/>

   输入账号密码: admin/admin，开始探索 Byzer Notebook 吧。

   <img src="/kolo-lang/zh-cn/introduction/images/explore_notebook_cn.png" alt="explore_notebook"/>
   

