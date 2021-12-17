# k8s 下的 Byzer-python 资源限制

Byzer-python 会单独在 Driver 或者 Executor 节点上启动一个 Python 进程（Python Worker）运行，默认总数量不超过节点的核数。

不过遗憾的是，如果不注意控制 Python 进程的资源占用，而 Byzer-engine 又跑在 K8s（Yarn 上也是类似情况）上，很可能导致容器被杀，如果是 Driver 节点被杀，那么会导致整个 Byzer-engine 失败。为了避免这种情况：

1. 连接 Ray 集群并且将处理逻辑都放到 Ray 里去完成（官方推荐）
2. 对 Python 代码所处的进程做资源限制

对于方式一，可以使用 `RayContext.foreach/RayContext.map_iter` 做处理。这样可以保证数据的交互无需经过 Python Worker。

下面是一个典型的例子：

```python
-- 准备数据
set jsonStr='''
{"SubProduct":"p1"},
{"SubProduct":"p2"},
{"SubProduct":"p3"},
{"SubProduct":"p4"},
''';
load jsonStr.`jsonStr` as data1;


!python env "PYTHON_ENV=source activate dev";
!python conf "schema=st(field(ProductName,string),field(SubProduct,string))";
!python conf "runIn=driver";
!python conf "dataMode=data";

run command as Ray.`` where 
inputTable="data1"
and outputTable="products"
and code='''
import ray
from pyjava.api.mlsql import RayContext
import numpy as np;


ray_context = RayContext.connect(globals(),"127.0.0.1:10001")


def echo(rows):
    for row in rows:
      row1 = {}
      row1["ProductName"]="jackm"
      row1["SubProduct"] = row["SubProduct"]
      yield row1


ray_context.map_iter(echo)
''';
```

`ray_context.map_iter`  会保证你的数据处理逻辑都运行在 Ray 集群上。对于上面的模式，仍然有个细节需要了解，就是 `map_iter` 里函数运行的次数，取决于数据表 `data1` 的分片数。如果你希望在函数里拿到所有数据，那么可以将 `data1` 的分片数设置为 1。

对于方式二，用户可以在容器里设置环境变量 `export PY_EXECUTOR_MEMORY=300` 或是在运行时配置 `!python conf "py_executor_memory=300";` ，这样表示 Python 内存不应该超过 300M。尽管如此，第二种方案还是有缺陷，如果你有 8 核，当多个用户并行使用时，最多会占用 2.4G 内存，很可能导致容器被杀死。

