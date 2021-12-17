## Quick Start

This chapter will introduce how to use the docker mirror environment to quickly experience Byzer Notebook.

### Prerequisites

[Install Docker](!https://www.docker.com/products/docker-desktop), ignore if it is already installed.

### Install Sandbox Image

1. Fetch Image

   `docker pull allwefantasy/mlsql-sandbox:<tag>`
   
   > tag corresponds to the version number of the mirror, [here](!https://hub.docker.com/r/allwefantasy/mlsql-sandbox/tags) list all available tags.
   
2. Run Container

   `docker run -d --name <container_name> -p <host_notebook__port>:9002 -p <host_byzer_port>:9003 -p <host_mysql_port>:3306 -e MYSQL_ROOT_PASSWORD=<mysql_pwd> allwefantasy/mlsql-sandbox:<tag>`
   
   > container_name is the container name you specified.
   > host_notebook_port is the host port of notebook service.
   > host_byzer_port is the host port of byzer engine.
   > host_mysql_port is the host port of mysql engine.
   > mysql_pwd is the password of mysql root account.
   > tag is the mirror version number of the previous step.
   
3. Visit in Browser

   Visit `http://localhost:9002` to start experiencing Byzer Notebook.
   
   The initial administrator account password is admin/admin.
   
### Installation Example

Next, we will demonstrate the entire quick installation process through examples. The command line parameter values ​​in the example are as follows:

- tag: 3.1.1-2.2.0
- container_name: byzer-sandbox
- host_notebook_port: 9002
- host_byzer_port: 9003
- host_mysql_port: 3306
- mysql_pwd: root

1. Fetch Image

   `docker pull allwefantasy/mlsql-sandbox:3.1.1-2.2.0`

   <img src="/byzer-notebook/en-us/introduction/images/fetch_sandbox_image.png" alt="fetch_image"/>
   
2. Run Container

   `docker run -d --name byzer-sandbox -p 9002:9002 -p 9003:9003 -p 3306:3306 -e MYSQL_ROOT_PASSWORD=root allwefantasy/mlsql-sandbox:3.1.1-2.2.0`
   
   <img src="/byzer-notebook/en-us/introduction/images/run_sandbox_container.png" alt="run_container"/>

3. Visit in Browser

   Visit `http://localhost:9002`
   

   <img src="/byzer-notebook/en-us/introduction/images/visit_notebook.png" alt="visit_notebook"/>
   
   Enter the account password: admin/admin, and start exploring Byzer Notebook.
   
   
   <img src="/byzer-notebook/en-us/introduction/images/explore_notebook_en.png" alt="explore_notebook"/>

   

   