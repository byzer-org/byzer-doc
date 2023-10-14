# Install and Understand Byzer in **3 minutes**

Choose the installation method that works best for your environment:<br>
Install with **Docker**, **Release Package**, and **Desktop Version**.

We strongly recommend that you use the **Release Package** method, because it can be well oriented to Standalone and Yarn-based distribution. Simply follow 3 steps:<br>

    1. Download
    2. Unzip and modify the configuration (optional)
    3. Start service

## Install Byzer Standalone
### Step1: Download
    Byzer-lang: https://download.byzer.org/latest/byzer-lang-all-in-one-linux-amd64-3.3.0-2.4.0-SNAPSHOT.tar.gz

    Byzer-notebook: https://download.byzer.org/latest/Byzer-Notebook-1.2.3.tar.gz

### Step2: Unzip

### Step3 Start

Start the Byzer-lang engine

Enter the [byzer-lang-all-in-one-linux-amd64-3.3.0-2.4.0-SNAPSHOT directory](https://download.byzer.org/latest/byzer-lang-all-in-one-linux-amd64-3.3.0-2.4.0-SNAPSHOT.tar.gz), execute the following command to start the Byzer engine:
```
./bin/byzer.sh start
```

After the startup is complete, you can access port 9003 (http://localhost:9003)

To start **Byzer Notebook**, you need to prepare a MySQL database in advance (version 5.7 is recommended), and then create a database named `notebook`.
Now you can enter `Byzer-Notebook-1.2.3`, and modify the `conf/notebook.properties` file, then modify the database configuration part according to the actual address of the database:

```
notebook.database.type=mysql
notebook.database.ip=127.0.0.1
notebook.database.port=3306
notebook.database.name=notebook
notebook.database.username=root
notebook.database.password=root
```
Now it's ready to start **Notebook** by

```
./bin/notebook.sh start
```

Visit port 9002 (http://localhost:9002), and enter the **Notebook** interface to start your project.

## Running the Development Server by **Yarn**

### Step 1: 
Download and Unzip spark-3.3.0: https://archive.apache.org/dist/spark/spark-3.3.0/spark-3.3.0-bin-hadoop3.tgz

### Step 2: 
Move `core-site.xml`, `yarn-site.xml`, and `hive-site.xml` into the `spark-3.3.0-bin-hadoop3/conf` directory

### Step 3: 
Copy server configuration in directory `byzer-lang-all-in-one-linux-amd64-3.3.0-2.4.0-SNAPSHOT/conf`

```
cp byzer.properties.server.example byzer.properties.overwrite
```

Start the engine:
```
export SPARK_HOME=xxxxxxx && ./bin/byzer.sh start
```

> Note: In specific cases, one of the two variables `HADOOP_HOME` or `YARN_CONF_DIR` may also need to be configured.

Now the Byzer engine will run on the Yarn cluster in `yarn-client` mode. You can access the http://localhost:9003 or use it directly through Notebook.

## Deployed in Kubernetes (Beta)
### Step 1
Add repo
```
helm repo add byzer http://store.mlsql.tech/charts
```
### Step 2
Install 
```
helm install -n byzer --create-namespace bz byzer/Byzer-lang \
--set clusterUrl=https://192.168.3.42:16443 \
--set fs.defaultFS=oss://xxxx \
--set fs.impl=org.apache.hadoop.fs.aliyun.oss.AliyunOSSFileSystem \
--set fs."oss\.endpoint"=oss-cn-hangzhou.aliyuncs.com \
--set fs."oss\.accessKeyId"=xxxx \
--set fs."oss\.accessKeySecret"=xxxxx
```

> Note: The engine needs an object storage or HDFS. Here it is configured with Alibaba Cloud OSS.

### Step3: 
Install **Byzer Notebook** (you need to configure a database and have a library named as `notebook`):):

```
helm install -n byzer --create-namespace nb byzer/Byzer-notebook \
--set name=nb \
--set engine=bz \
--set notebook."database\.ip"=192.168.3.14 \
--set notebook."database\.username"=xxx \
--set notebook."database\.password"=xxxx
```

Congratulations! Now you can access the **Notebook** to see what's available.

For more info, visit https://github.com/byzer-org/byzer-helm

