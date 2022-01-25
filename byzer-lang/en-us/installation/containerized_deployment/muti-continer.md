# Multi-container deployment

### Prerequisites

#### Install Docker Desktop

Install Docker Desktop. You can find the detailed steps in [Sandbox standalone deployment](/byzer-lang/en-us/installation/containerized_deployment/sandbox-standalone.md).

#### Download the build project

Multi-container deployment requires a `docker-compose.yaml`  to define the services of the application, so that they can run together in a segregated environment. To facilitate the operation, please download the open-source project — byzer-build, which provides the complete docker compose configuration. The operation process will be demonstrated below.

Clone the code from the main branch:

```shell
git clone https://github.com/byzer-org/byzer-build.git byzer-build
cd byzer-build && git checkout main && git pull -r origin main
```

#### Set environment variables

```
## specify the MySQL root user password
export MYSQL_ROOT_PASSWORD=root
## MySQL port number
export MYSQL_PORT=3306
## Background management service port of Byzer engine
export KOLO_LANG_PORT=9003
## Byzer Notebook client port
export BYZER_NOTEBOOK_PORT=9002
## spark version used by Byzer (for generating container name)
export SPARK_VERSION=3.1.1
##Byzer-lang version (for generating container name)
export KOLO_LANG_VERSION=2.2.0-SNAPSHOT
## Byzer Notebook version (for generating the container name)
export BYZER_NOTEBOOK_VERSION=0.0.1-SNAPSHOT
```

> Note: All the above environment variables are configured with default values. You can skip this step if you do not need customization. 


### Build Byzer Images with scripts

Run the following script to build images in the local repository, to facilitate the starting of the container.

```
sh -x dev/bin/build-images.sh
```

### Deploy Byzer with multiple containers

Multi-container deployment is different from the sandbox standalone deployment method. Basically, it is to build multiple services in one image, so they can be started together in a unified way. These services are:

- `mysql:8.0-20.04_beta`: MySQL database for storing metadata and data in Byzer Notebook

- `byzer-lang`: Byzer runtime engine

- `byzer-notebook`: Byzer visualized management platform

### Run scripts for multi-container deployment

```
sh -x dev/bin/docker-compose-up.sh
```

The above script uses  `docker-compose up`  to start the service:

```shell
cd dev/docker

docker-compose up -d
```
