# Byzer-python

Byzer-lang 可以通过 Byzer-python 去拥抱 Python 生态。利用 Byzer-python，用户不仅仅可以进行使用 Python 进行 ETL 处理，比如可以将一个 Byzer 表转化成一个分布式DataFrame on Dask 来操作， 也可以使用 Byzer-python 高阶 API 来完成数据处理。此外，用户还能实现对各种机器学习框架的支持，比如 Tensorflow，Sklearn，PyTorch。

Byzer-python 核心在于，实现了 Byzer 表在 Python 中的无缝衔接， 用户可以通过 Byzer-python API 获取表，处理完成后输出表， 表的形态甚至支持模型目录。

#### Hello World

```sql
-- Byzer-python Hello World

!python env "PYTHON_ENV=source activate python3.6";
!python conf "schema=st(field(hello,string))";
!python conf "dataMode=model";
!python conf "runIn=driver";

run command as Ray.`` where 
inputTable="command"
and outputTable="output"
and code='''
import ray
from pyjava.api.mlsql import RayContext,PythonContext

ray_context = RayContext.connect(globals(),None)
context.build_result([{"hello":"world"}])
''';
```



