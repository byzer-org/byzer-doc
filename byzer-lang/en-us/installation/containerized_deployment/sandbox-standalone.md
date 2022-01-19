# Sandbox independent deployment

Sandbox has Byzer's two major parts, Byzer Notebook and Byzer Lang, you can quickly experience Byzer's functions.

### Prerequisites

#### Install Docker Desktop

Docker Desktop is an application for MacOS and Windows for building and sharing containerized applications and microservices. It provides a management platform, which is convenient for us to quickly deploy and manage Sandbox images and containers.

Download the installation package suitable for your operating system from [Docker official website](https://www.docker.com/products/docker-desktop).

The Docker desktop community for Linux is still under development, you can refer to [Docker official website installation documentation](https://docs.docker.com/engine/install/ubuntu/) to install Docker engine on Linux.

### Sandbox independently deploys Byzer

Download the latest image of the byzer docker repo (based on Spark 3):

```shell
docker pull byzer/byzer-sandbox:3.1.1-2.2.0-SNAPSHOT
```

If you need to experience the byzer spark2, please download the latest image of the byzer docker repo:

```shell
docker pull byzer/byzer-sandbox:2.4.3-2.2.0-SNAPSHOT
```

Run the Sandbox container of Spark 3.1.1 by using docker command:

```shell
docker run -d \
-p 3306:3306 \
-p 9002:9002 \
-p 9003:9003 \
-e MYSQL_ROOT_HOST=% \
-e MYSQL_ROOT_PASSWORD=root \
--name sandbox-3.1.1-2.2.0-SNAPSHOT \
--restart=always \
byzer/byzer-sandbox:3.1.1-2.2.0-SNAPSHOT
```

Run the Sandbox container of Spark 2.4.3 by using docker command:

```shell
docker run -d \
-p 3306:3306 \
-p 9002:9002 \
-p 9003:9003 \
--name sandbox-2.4.3-2.2.0-SNAPSHOT \
--restart=always \
-e MYSQL_ROOT_HOST=% \
-e MYSQL_ROOT_PASSWORD=root \
byzer/byzer-sandbox:2.4.3-2.2.0-SNAPSHOT
```

> Note: if pulling image times out when running container, you only need to run a Sandbox image.


### Experience Byzer's functions

In the browser, click to [Login](http://localhost:9002), and enter your user name and password in the user registration page. In the next page, click Create a New Notebook - >Create to enter the Notebook interface and enter the code as shown below.

#### Process JSON data by using Python and Ray

Please execute the code:

```sql
-- Build test data
set mockData='''

{"title":"First","body":"Content 1"}
{"title":"Second","body":"Content 2"}
{"title":"Third","body":"Content 3"}

''';

load jsonStr.`mockData` as data;

-- Set up the Python environment
!python env "PYTHON_ENV=:";
!python conf "runIn=driver";
!python conf "schema=st(field(title,string),field(body,string))";
!python conf "dataMode=data";

-- Python code is executed on Sandbox built-in Ray
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

The result is as follows:

<img src="/byzer-lang/zh-cn/installation/containerized_deployment/images/python-ray-result.PNG" alt="Python-Ray results"/>

#### Porcess MySQL data

```sql
-- Load mlsql_console.mlsql_job table data
load jdbc.`usage_template` where url="jdbc:mysql://localhost:3306/notebook?characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&tinyInt1isBit=false"
and driver="com.mysql.jdbc.Driver"
and user="root"
and password="root"
as table1;

-- Query 100
select * from table1 limit 100 as table2;

-- Save to DeltaLake
save append table2 as delta.`dt1`;

-- Query DeltaLake
load delta.`dt1` as table3;

select * from table3 as table4;
```

The result is as follows:

<img src="/byzer-lang/zh-cn/installation/containerized_deployment/images/mysql-deltalake.PNG" alt="MySQL-deltalake"/>