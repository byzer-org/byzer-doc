# Byzer-python

Byzer-lang can leverage Python ecology through Byzer-python. With Byzer-python, users can process ETL by using Python. For example, users can convert a Byzer table into a distributed DataFrame on Dask.  Users can also process data by using advanced API of Byzer-python. In addition, Byzer-python also supports for various machine learning frameworks such as Tensorflow, Sklearn and PyTorch.

The core of Byzer-python is that it realizes the seamless connection of Byzer tables in Python. Users can obtain tables through Byzer-python API and output tables after processing. The form of tables even supports model catalogs.

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



