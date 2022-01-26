# Environment dependence

Before using Byzer-python, configure Python environment on the node that requires Driver (Executor node is optional). If you use yarn for cluster management, it is recommended to use Conda to manage Python Environment (refer to [Conda Environment Installation](https://conda.io/projects/conda/en/latest/user-guide/install/index.html)). If you use K8s, you can use image management directly.

Next, we take Conda as an example to introduce the process of creating a Byzer-python environment.

## Python environment setup

Create a Python 3.6.13 environment named `dev`

```shell
conda create -n dev python=3.6.13
```

Activate dev environment

```shell
source activate dev
```

Install the following dependent package

```
pyarrow==4.0.1
ray[default]==1.8.0
aiohttp==3.7.4
pandas>=1.0.5; python_version < '3.7'
pandas>=1.2.0; python_version >= '3.7'
requests
matplotlib~=3.3.4
uuid~=1.30
pyjava
```

## Ray environment setup (optional)

Ray relies on Python environment. Here, the Python 3.6 environment created in the previous section is used to deploy Ray.

### Stand-alone startup

```shell
ray start --head
```

If you see the following log, it indicates that the startup was successful:
<p align="center">
<img src="/byzer-lang/en-us/python/image/image-ray-started.png" title="image-ray-started" width="600"/>
</p>

Run the Python code given in the log above to test whether it can connect to the Ray node normally:

```python
import ray
ray.init(address="ray://<head_node_ip_address>:10001")
```

<p align="center">
<img src="/byzer-lang/en-us/python/image/image-ray-test.png" title="ray-test" width="800"/>
</p>


> If the following error occurs, it may be a problem with the version of Conda virtual environment. It is recommended to reinstall it. For more information, see [Ray Issue #19938](https://github.com/ray-project/ray/issues/19938).
>
><img alt="image-ray-error" src="/byzer-lang/en-us/python/image/image-ray-error.png" width="800"/>

### Cluster startup

Run on the Head node

```shell
ray start --head
```

Run on the Worker node

```shell
ray start --address='<head_node_ip_address>:6379' --redis-password='<password>'
```

<p align="center">
<img alt="image-ray-cluster.png" src="/byzer-lang/en-us/python/image/image-ray-cluster.png" width="800"/>
</p>


> This simply starts the Ray environment. For more information, see [Ray official documentation](https://docs.ray.io/en/releases-1.8.0/)

Execute distributed use case:

```sql
-- distribute python hello world

set jsonStr='''
{"Busn_A":114,"Busn_B":57},
{"Busn_A":55,"Busn_B":134},
{"Busn_A":27,"Busn_B":137},
{"Busn_A":101,"Busn_B":129},
{"Busn_A":125,"Busn_B":145},
{"Busn_A":27,"Busn_B":60},
{"Busn_A":105,"Busn_B":49}
''';

load jsonStr.`jsonStr` as data;

!python env "PYTHON_ENV=source activate dev";
!python conf "schema=st(field(ProductName,string),field(SubProduct,string))";
!python conf "dataMode=data";
!python conf "runIn=driver";

run command as Ray.`` where
inputTable="data"
and outputTable="python_output_table"
and code='''
from pyjava.api.mlsql import PythonContext,RayContext

# type hint
context:PythonContext = context

ray_context = RayContext.connect(globals(),"127.0.0.1:10001")

def echo(row):
    row1 = {}
    row1["ProductName"]=str(row['Busn_A'])+'_jackm'
    row1["SubProduct"] = str(row['Busn_B'])+'_product'
    return row1

ray_context.foreach(echo)
''';
```

## Byzer-python and Ray

<p align="center">
<img alt="image-infra" src="/byzer-lang/en-us/python/image/image-infra.png" width="800"/>
</p>


In the previous Hello World example, the script was executed on the Java Executor node, then Byzer-python code is passed to Python Worker for execution. At this time, because there is no connection to the Ray cluster, all logical processing work is completed in Python Worker and performed standalone execution.

In the above distributed Hello World example, by connecting to the Ray Cluster Python Worker is converted into a Ray Client, which is only responsible for converting Byzer-python code into tasks and submitting them to Ray Cluster. So in distributed computing scenarios, Python Worker can be very lightweight. Except for the basic Ray, Pyjava and other databases, you do not need to install additional Python dependent libraries.

