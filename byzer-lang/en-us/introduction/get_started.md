# Quick Start

This chapter will introduce how to use the Docker mirror environment to quickly experience Byzer's IDE application platform-Byzer Notebook.

### Prerequisite

[Install Docker](https://www.docker.com/products/docker-desktop). Please skip this process if you already installed Docker.

### Install Sandbox Mirror

1. Acquire mirror

   `docker pull byzer/byzer-sandbox:<tag>`

   > Each tag corresponds to a mirror version number. Click [Here](https://hub.docker.com/r/byzer/byzer-sandbox/tags) to view all available tags.

3. Run container

   `docker run -d --name <container_name> -p <host_notebook__port>:9002 -p <host_byzer_port>:9003 -p <host_mysql_port>:3306 -e MYSQL_ROOT_PASSWORD=<mysql_pwd> byzer/byzer-sandbox:<tag>`

   Parameter specification：

   - container_name：container name
   - host_notebook_port: the port exposed by notebook on the host server
   - host_byzer_port: the port exposed by byzer on the host server
   - host_mysql_port: the port exposed by mysql on the host server
   - mysql_pwd: root account number and password of mysql
   - Tag：the selected mirror version number in last process

4. Access Byzer Notebook

   Enter `http://localhost:9002` in address bar to experience Byzer Notebook。

   Initial Admin account number and password：admin/admin

### Examples of installation

We will use examples to demonstrate the entire quick installation process. The command line parameters are as follows：

- tag: 3.1.1-2.2.0
- container_name: byzer-sandbox
- host_notebook_port: 9002
- host_byzer_port: 9003
- host_mysql_port: 3306
- mysql_pwd: root

1. Acquire mirror

   `docker pull byzer/byzer-sandbox:3.1.1-2.2.0`

2. Run container

   `docker run -d --name byzer-sandbox -p 9002:9002 -p 9003:9003 -p 3306:3306 -e MYSQL_ROOT_PASSWORD=root byzer/byzer-sandbox:3.1.1-2.2.0`

<img src="/byzer-lang/zh-cn/introduction/images/run_sandbox_container.png" alt="run_container"/>

3. Access Byzer Notebook

   Enter `http://localhost:9002` in address bar.


![visit_notebook](image/visit_notebook.png)

Enter your account number and password: admin/admin to explore Byzer Notebook.

![explore_notebook](image/explore_notebook_en.png)

