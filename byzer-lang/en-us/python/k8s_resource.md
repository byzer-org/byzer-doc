# Byzer-python resource restriction under K8S

Byzer-python will run a Python Worker on Driver or Executor node alone and the default total number does not exceed the number of node coreness. Unfortunately, if you do not control the resource consumption of Python Worker and Byzer-engine runs on K8s (similar to Yarn), it may cause the container to be killed. If the Driver node is killed, it will cause the entire Byzer-engine to fail. To avoid this:

1. Connect to Ray cluster and process logics in Ray (official recommendation).
2. Set resource restriction on Python Worker where Python code resides.

For method 1, you can use `RayContext.foreach/RayContext.map_iter` for processing. This ensures that data interaction does not need to go through Python Worker.

Example:

```python
-- prepare data
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

`ray_context.map_iter` will ensure that your data processing logic runs on Ray cluster. For the above mode, you should know the number of times that the function runs in `map_iter` depends on the fragmentation number of the data table `data1`. If you want to get all data in the function, you can set the fragmentation number of `data1` to 1.

For method 2, users can set the environment variable `export PY_EXECUTOR_MEMORY=300` in the container or configure `!python conf "py_executor_memory=300";` at runtime, which means the maximum Python memory size is 300M. However, the second method still has a shortage. If you have 8 cores, when multiple users use it in parallel, it will take up to 2.4G of memory, which is likely to cause the container to be killed.

