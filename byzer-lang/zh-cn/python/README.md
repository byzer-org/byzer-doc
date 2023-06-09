# Byzer-python

Byzer通过 Byzer-python 扩展（内置）来支持Python 代码。

通过 Byzer-python，用户不仅仅可以进行

1. 使用 Python 进行 ETL 处理，比如可以将一个 Byzer 表转化成一个分布式DataFrame on Dask 来操作， 
2. 支持各种机器学习框架，比如 Tensorflow，Sklearn，PyTorch。

用户的Python脚本在 Byzer中是黑盒，用户可以通过固定API获得表数据，通过固定API来将Python输出转化为表，方便后续SQL处理。

#### Hello World

```sql
-- Byzer-python Hello World
select "world" as hello as table1;

!python conf "schema=st(field(hello,string))";
!python conf "pythonExec=/home/winubuntu/miniconda3/envs/byzerllm-desktop/bin/python";
!python conf "dataMode=model";
!python conf "runIn=driver";

run command as Ray.`` where 
inputTable="table1"
and outputTable="new_table"
and code='''
import ray
from pyjava.api.mlsql import RayContext,PythonContext

ray_context = RayContext.connect(globals(),None)

rows_from_table1 = [item for item in ray_context.collect()]

for row in rows_from_table1:
   row["hello"] = "Byzer-Python"

context.build_result(rows_from_table1)
''';

select * from new_table as output;
```

简单描述下上面的代码。

1. 第一步我们通过SQL获取到 table1.
2. 第二步我们设置一些配置参数
3. 第三步我们通过 Ray 扩展来书写 Python 代码对 table1 里的每条记录做处理。
4. 第四步我们把 Python处理的结果得到的表 new_table 进行输出。

当然，上面的hello world 代码无法处理大规模数据。我们在后续教程中会进行更详细的介绍。



