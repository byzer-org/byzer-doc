# PyJava API简介

前面的示例中，可以看到类似 `RayContext`、 `PythonContext` 这些对象。这些对象帮助用户进行输入和输出的控制。

Byzer-python 代码编写三步走：

### 1. 初始化 `RayContext`

```Python
ray_context = RayContext.connect(globals(), "192.168.1.7:10001")
```

其中第二个参数是可选的，用来设置 Ray 集群 Master 节点地址和端口。如果不需要连接 Ray 集群，则设置为 `None` 即可。

### 2. 获取数据

获取所有数据：

```python
# 获取 DataFrame
data = ray_context.to_pandas()

# 获取一个返回值为 dict 类型的生成器
items = ray_context.collect()
```

> 注意，`ray_context.collect()` 得到的生成器只能迭代一次。

通过分片来获取数据：

```Python
data_refs = ray_context.data_servers()

data = [RayContext.collect_from([data_ref]) for data_ref in data_refs]
```

> 注意，`data_refs` 是字符串数组，每个元素是一个 `ip:port` 的形态. 可以使用 `RayContext.collect_from`  单独获取每个数据分片。
>

如果数据规模大，可以转化为 Dask 数据集来进行操作：

```Python
data = ray_context.to_dataset().to_dask()
```

### 3. 构建新的结果数据输出

```Python
context.build_result(data) 
```

> 这里 `PythonContext.build_result` 的入参 `data` 是可迭代对象，支持数组、生成器等

现在引入下面两个 API 用来做数据分布式处理：

#### 1) RayContext.foreach

如果已经连接了 Ray，那么可以直接使用高阶 API `RayContext.foreach`

```sql
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
and outputTable="data2"
and code='''
import ray
from pyjava.api.mlsql import RayContext,PythonContext

context:PythonContext = context
ray_context = RayContext.connect(globals(),"127.0.0.1:10001")

def echo(row):
    row1 = {}
    row1["ProductName"]=str(row['a'])+'_jackm'
    row1["SubProduct"] = str(row['b'])+'_product'
    return row1
buffer = ray_context.foreach(echo)
''';
```

`RayContext.foreach` 接收一个回调函数，函数的入参是单条记录。无需显示的申明如何获取数据，只要实现回调函数即可。

#### 2) RayContext.map_iter

我们也可以获得一批数据，可以使用 `RayContext.map_iter`。

系统会自动调度多个任务到 Ray 上并行运行。 `map_iter` 会根据表的分片大小启动相应个数的 task，如果你希望通过 `map_iter` 拿到所有的数据，而非部分数据，可以先对表做重新分区:

```sql
!python env "PYTHON_ENV=source activate dev";
!python conf "schema=st(field(ProductName,string),field(SubProduct,string))";
!python conf "dataMode=data";
!python conf "runIn=driver";

run command as Ray.`` where 
inputTable="data"
and outputTable="data2"
and code='''
import ray
from pyjava.api.mlsql import RayContext
import numpy as np;
import time
ray_context = RayContext.connect(globals(),"127.0.0.1:10001")

def echo(rows):
    count = 0
    for row in rows:
      row1 = {}
      row1["ProductName"]="jackm"
      row1["SubProduct"] = str(row["Busn_A"])+'_'+str(row["Busn_B"])
      count = count + 1
      if count%1000 == 0:
          print("=====> " + str(time.time()) + " ====>" + str(count))
      yield row1

ray_context.map_iter(echo)
''';
```

#### 3) 将表转化为分布式 `DataFrame`

如果用户喜欢使用 Pandas API，而数据集又特别大，也可以将数据转换为分布式 DataFrame on Dask 来做进一步处理：

```sql
!python env "PYTHON_ENV=source activate dev";
!python conf "schema=st(field(count,long))";
!python conf "dataMode=model";
!python conf "runIn=driver";

run command as Ray.`` where 
inputTable="data"
and outputTable="data2"
and code='''
from pyjava.api.mlsql import PythonContext,RayContext
context:PythonContext = context

ray_context = RayContext.connect(globals(),"127.0.0.1:10001")
df = ray_context.to_dataset().to_dask()
c = df.shape[0].compute()
context.build_result([{"count":c}])
''';
```

> 1. 使用该 API 需要连接到 Ray，需要配置节点地址。
> 2. 对应的 Python 环境需要预先安装好 dask ，`pip install "dask[complete]"`

#### 4) 将目录转化为表

这个功能在做算法训练的时候特别有用。比如模型训练完毕后，一般是保存在训练所在的节点上的。我们需要将其转化为表，并且保存到数据湖里去。具体操作如下：

首先，通过 Byzer-python 读取目录，转化为表：

```sql
!python env "PYTHON_ENV=source activate dev";
!python conf "schema=file";
!python conf "dataMode=model";
!python conf "runIn=driver";


run command as Ray.`` where 
inputTable="train_data"
and outputTable="model_output"
and code='''
import os
from pyjava.storage import streaming_tar
from pyjava.api.mlsql import PythonContext,RayContext

context:PythonContext = context
ray_context = RayContext.connect(globals(), None)

# train your model here
......

model_path = os.path.join("/","tmp","ai_model/model")
your_model.save(model_path)

model_binary = [item for item in streaming_tar.build_rows_from_file(model_path)]

context.build_result(model_binary)
''';
```

将 Byzer-python 产生的表保存到数据湖里

```sql
save overwrite model_output as delta.`ai_model.model_output`;
```

