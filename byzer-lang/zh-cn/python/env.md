# 环境依赖

在使用 Byzer-python 前，需要 Driver 的节点上配置好 Python 环境 ( Executor 节点可选) 。如果您使用 yarn 做集群管理，推荐使用 Conda 管理 Python
环境（参考[Conda 环境安装](https://conda.io/projects/conda/en/latest/user-guide/install/index.html)）。而如果您使用 K8s，则可直接使用镜像管理。

接下来，我们以 Conda 为例，介绍创建 Byzer-python 环境的流程。

### 1. Python 环境搭建

创建一个名字为 dev 的 Python 3.6.13 环境

```shell
conda create -n dev python=3.6.13
```

激活 dev 环境

```shell
source activate dev
```

安装以下依赖包

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

### 2. Ray 环境搭建（可选）

Ray 依赖 Python 环境，这里使用前文创建的 Python 3.6 环境部署 Ray。

#### 1) 单机启动

```shell
ray start --head
```

看到以下日志说明启动成功：
<p align="center">
<img src="/byzer-lang/zh-cn/python/image/image-ray-started.png" title="image-ray-started" width="600"/>
</p>
运行上文日志中给出的 Python 代码，测试能否正常连接到 Ray 节点：

```python
import ray
ray.init(address="ray://<head_node_ip_address>:10001")
```

<p align="center">
<img src="/byzer-lang/zh-cn/python/image/image-ray-test.png" title="ray-test" width="800"/>
</p>

> 如果出现下方报错可能是 Conda 虚拟环境版本问题，建议重新安装，更多信息见[Ray Issue #19938](https://github.com/ray-project/ray/issues/19938)。
>
> <img alt="image-ray-error" src="/byzer-lang/zh-cn/python/image/image-ray-error.png" width="800"/>

#### 2) 集群启动

在 Head 节点上运行

```shell
ray start --head
```

Worker 节点上运行

```shell
ray start --address='<head_node_ip_address>:6379' --redis-password='<password>'
```

<p align="center">
<img alt="image-ray-cluster.png" src="/byzer-lang/zh-cn/python/image/image-ray-cluster.png" width="800"/>
</p>

> 这里只是简单地启动了 Ray 环境，更多配置信息可参考 [Ray 官方文档](https://docs.ray.io/en/latest/)

执行分布式用例：

```sql
-- 分布式获取 python hello world

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

### 3. Byzer-python 与 Ray

<p align="center">
<img alt="image-infra" src="/byzer-lang/zh-cn/python/image/image-infra.png" width="800"/>
</p>

在上一篇 Hello World 例子中， 脚本在 Java Executor节点执行，然后再把 Byzer-python 代码传递给 Python Worker 执行。此时因为没有连接 Ray 集群，所以所有的逻辑处理工作都在
Python Worker 中完成，并且是单机执行。

在上文分布式的 Hello World 示例中， 通过连接 Ray Cluster, Python Worker 转化为 Ray Client，只负责把 Byzer-python 代码转化为任务提交给 Ray
Cluster，所以在分布式计算场景下 Python Worker 可以很轻量，除了基本的 Ray，Pyjava 等库以外，不需要安装额外的 Python 依赖库。

