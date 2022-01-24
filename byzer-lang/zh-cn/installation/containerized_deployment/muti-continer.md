# Multi-container deployment

### Prerequisites

#### Install Docker Desktop

Please install Docker Desktop. For more information, read [Sandbox standalone deployment](/byzer-lang/en-us/installation/containerized_deployment/sandbox-standalone.md).

#### Download the build project

Multi-container deployment requires a service to define the services that make up the application so that they can run together in an isolated environment. For ease of use, please download the open source project — byzer-build, which provides a complete docker compose configuration. The specific operation process will be demonstrated below.

Download and get the code of trunk:

```shell
git clone https://github.com/byzer-org/byzer-build.git byzer-build
cd byzer-build && git checkout main && git pull -r origin main
```

#### Set environment variables

```
## specify the mysql root user password
export MYSQL_ROOT_PASSWORD=root
## mysql port number
export MYSQL_PORT=3306
## Byzer engine background management service port
export KOLO_LANG_PORT=9003
## byzer notebook client port
export BYZER_NOTEBOOK_PORT=9002
## spark version used by byzer (for generating container name)
export SPARK_VERSION=3.1.1
## byzer lang version (for generating container name)
export KOLO_LANG_VERSION=2.2.0-SNAPSHOT
## byzer notebook version (for generating the container name)
export BYZER_NOTEBOOK_VERSION=0.0.1-SNAPSHOT
```

> Note: we have provided default values ​​for all the above environment variables. If you do not need to customize the configuration, you can leave them alone.


### Build Byzer Images with scripts

Running the following script will build images to the local repository, which is convenient for running container later.

```
sh -x dev/bin/build-images.sh
```

### Deploy Byzer with multiple containers

Multi-container deployment is different from the sandbox standalone deployment method. In essence, each of multiple services is built as an image, and then started together in a unified way. These services are as follows:

- mysql:8.0-20.04_beta: mysql database for storing metadata and data in byzer-notebook

- byzer-lang: Byzer's runtime engine

- byzer-notebook: Byzer's visual management platform

### Execute scripts for multi-container deployment

```
sh -x dev/bin/docker-compose-up.sh
```

The service inside the above script is started through the `docker-compose up` command:

```shell
cd dev/docker

docker-compose up -d
```
