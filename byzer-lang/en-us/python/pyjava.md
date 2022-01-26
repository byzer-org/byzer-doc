# PyJava API introduction

In the previous example, you can see objects like `RayContext` and `PythonContext`. These objects help users with input and output controls.

There are three steps to write Byzer-python code:

#### 1. Initialize `RayContext`

```Python
ray_context = RayContext.connect(globals(), "192.168.1.7:10001")
```

The second parameter is optional and is used to set the address and port of Ray cluter's Master node. If you do not need to connect to Ray cluster, set it to `None` .

#### 2. Get data

Get all data:

```python
# get DataFrame
data = ray_context.to_pandas()

# get a generator whose return value is dict
items = ray_context.collect()
```

> Note: the generator obtained by `ray_context.collect()` can only be iterated once.

Get data by fragmentation:

```Python
data_refs = ray_context.data_servers()

data = [RayContext.collect_from([data_ref]) for data_ref in data_refs]
```

> Note: `data_refs` is an array of character strings and the form of each element is `ip:port`. Each data fragmentation can be obtained individually by using `RayContext.collect_from`.
>

If data scale is large, it can be converted into a Dask dataset to operate:

```Python
data = ray_context.to_dataset().to_dask()
```

#### 3. Build new result data output

```Python
context.build_result(data)
```

> Here The input parameter `data` of `PythonContext.build_result` is an iterable object that supports arrays, generators, etc.

Now introduce the following two APIs for data distributed processing:

#### RayContext.foreach

If Ray is already connected, you can use advanced API `RayContext.foreach` directly.

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

`RayContext.foreach` receives a callback function whose input parameter is a single record. You do not need to explicitly declare how to get data, just implement the callback function.

#### RayContext.map_iter

We can also get a batch of data by using `RayContext.map_iter`.

The system will automatically schedule multiple tasks to run on Ray in parallel. `map_iter` will start the corresponding number of tasks according to the fragmentation size of the table. If you want to get all data through `map_iter` instead of part of data, you can repartition for tables:

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

#### Convert table to distributed `DataFrame`

If tusers prefer to use Pandas API and the dataset is particularly large, data can also be converted to distributed DataFrame on Dask for further processing:

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

> 1. To use this API, you need to connect to Ray and configure the node address.
> 2. You also need to install dask on the corresponding Python environment in advance, `pip install "dask[complete]"`

#### Convert a director into a table

This function is especially useful when doing algorithm training. For example, after model training, the directory is generally saved on the node where model training is located. We need to convert it into a table and save it to the data lake. The specific operations are as follows:

First, read the directory through Byzer-python and convert it into a table:

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

context: PythonContext = context
ray_context = RayContext.connect(globals(), None)

# train your model here
......

model_path = os.path.join("/","tmp","ai_model/model")
your_model.save(model_path)

model_binary = [item for item in streaming_tar.build_rows_from_file(model_path)]

context.build_result(model_binary)
''';
```

Save the table generated by Byzer-python to the data lake

```sql
save overwrite model_output as delta.`ai_model.model_output`;
```

