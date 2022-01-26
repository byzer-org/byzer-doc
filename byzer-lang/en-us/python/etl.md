# Data processing

First, build a set of test data for later demonstrations.

```sql
set jsonStr='''
{"features":[5.1,3.5,1.4,0.2],"label":0.0},
{"features":[5.1,3.5,1.4,0.2],"label":1.0},
{"features":[5.1,3.5,1.4,0.2],"label":0.0},
{"features":[4.4,2.9,1.4,0.2],"label":0.0},
{"features":[5.1,3.5,1.4,0.2],"label":1.0},
{"features":[5.1,3.5,1.4,0.2],"label":0.0},
{"features":[5.1,3.5,1.4,0.2],"label":0.0},
{"features":[4.7,3.2,1.3,0.2],"label":1.0},
{"features":[5.1,3.5,1.4,0.2],"label":0.0},
{"features":[5.1,3.5,1.4,0.2],"label":0.0}
''';
load jsonStr.`jsonStr` as data;
```

Save to data lake:

```sql
save overwrite data as delta.`example.mock_data`;
```

Load `mock_data` in the data lake and process it to get `sample_data`.

```sql
load delta.`example.mock_data` as example_data;
select features[0] as a ,features[1] as b from example_data
as sample_data;
```

## Byzer-python process data

If you want to run Byzer-python code in a virtual environment, you can specify Python virtual environment you want to use with the following command:

```sql
!python env "PYTHON_ENV=source activate dev";
```

> 1. `source activate dev` can be replaced with absolute path `source /path/to/activate dev`.
>
> 2. If there is no virtual environment, configure it as `"PYTHON_ENV=:"` .

Then specify whether the code is executed on Driver or Executor. It is recommended to execute on Driver:

```sql
!python conf "runIn=driver";
```

If `RayContext.foreach` or `RayContext.map_iter` is used in the code, set `dataMode` to `data` or `model`. In this example, we set it to `model`:

```sql
!python conf "dataMode=model";
```

Now specify the data format returned by the Python script: if it returns a table, you can define the name and type of each field by setting `schema=st(field({name},{type})...)` ; if it returns a file, `schema=file` can be set.

```sql
!python conf "schema=st(field(_id,string),field(x,double),field(y,double))";
```

The correspondence between `schema` field type and Python:

| Python type | Schema field type | Example (Python data: schema definition) |
|----------| --------------- |---------------------------------------------------------------------------------------------------------------------|
| `int` | `long` | `{"int_value": 1}` ：`"schema=st(field(int_value,long))"` |
| `float` | `double` | `{"float_value": 2.1}` ：`"schema=st(field(float_value,double))"` |
| `str` | `string` | `{"str_value": "Everything is a table!"}` ：`"schema=st(field(str_value,string))"` |
| `bool` | `boolean` | `{"bool_value": True}` ：`"schema=st(field(bool_value,boolean)"` |
| `list` | `array` | `{"list_value": [1.0, 3.0, 5.0]}`：`"schema=st(field(list_value,array(double)))"` |
| `dict` | `map` | `{"dict_value": {"list1": [1, 3, 5], "list2": [2, 4, 6]}}` ：`"schema=st(field(dict_value,map(string,array(long))))"` |
| `bytes` | `binary` | `{"bytes_value": b"Everything is a table!"}` ：`"schema=st(field(bytes_value,binary))"` |

> The above four configurations are all session-level and it is recommended to manually specify these configurations each time when executing Python script.

Run Python script to process the table `sample_data`:

```sql
run command as Ray.`` where
inputTable="sample_data"
and outputTable="python_output_table"
and code='''
import ray
from pyjava.api.mlsql import RayContext

ray_context = RayContext.connect(globals(), None)
datas = RayContext.collect_from(ray_context.data_servers())
id_count = 1

def handle_record(row):
    global id_count
    item = {"_id": str(id_count)}
    id_count += 1
    item["x"] = row["a"]
    item["y"] = row["b"]
    return item

result = map(handle_record, datas)
context.build_result(result)
''';
```

<p align="center">
<img src="/byzer-lang/en-us/python/image/image-etl-1.png" title="image-etl-1" height="400"/>
</p>


## Byzer-python code description

Note: Python script runs as a character string parameter in the code, which is a template for Byzer-Python code. The parameter `inputTable` specifies the table to be processed. If there is no table to be processed, it can be set to `command`; the parameter `outputTable` specifies the name of the output table; the parameter `code` is the Python script to be executed.

```sql
run command as Ray.`` where
inputTable="sample_data"
and outputTable="python_output_table"
and code='''
import ray
......
''';
```

Input Python script:

```python
## Import necessary packages
import ray
from pyjava.api.mlsql import RayContext

## Get ray_context, if you need to use a ray cluster, then in the second parameter fills in the address of Master cluster node.
## Otherwise set to None.
ray_context = RayContext.connect(globals(), None)

# Get all data sources through ray_context.data_servers(), if Ray is enabled, then you can;6
# get these data distributed for processing.
datas = RayContext.collect_from(ray_context.data_servers())
id_count = 1

## The data format accepted from java is also list (dict). It means the data of each row is stored as a data structure of the dictionary.
## For example, data of sample_data's structure from Python is
## [{'a':'5.1','b':'3.5'}, {'a':'5.1','b':'3.5'}, {'a':'5.1','b ':'3.5'} ...]
## Based on this data structure, we process input data
def handle_record(row):
    global id_count
    item = {"_id": str(id_count)}
    id_count += 1
    item["x"] = row["a"]
    item["y"] = row["b"]
    return item

result = map(handle_record, datas)

## Here result is an iterator, context.build_result also supports importing generators/arrays
context.build_result(result)
```

The Byzer-python code above is written in native Byzer-lang code. In Byzer Notebook and Byzer Desktop, you can use **annotations** to configure `!python` configuration items and input and output tables `inputTable/outputtable` mentioned above. At this time, the writing of Byzer-python code is the same as that of ordinary Python scripts:

```python
#%python
#%env=source activate dev
#%input=sample_data
#%output=python_output_table
#%runIn=driver
#%dataMode=model
#%schema=st(field(_id,string),field(x,float),field(y,float))

import ray
from pyjava.api.mlsql import RayContext

ray_context = RayContext.connect(globals(), None)
datas = RayContext.collect_from(ray_context.data_servers())
id_count = 1

def handle_record(row):
    global id_count
    item = {"_id": str(id_count)}
    id_count += 1
    item["x"] = row["a"]
    item["y"] = row["b"]
    return item

result = map(handle_record, datas)
context.build_result(result)
```

## Byzer-python reads and writes Excel files

Python has many libraries for processing Excel files its functions are mature and complete. You can install the corresponding libraries in Byzer-python environment to process your Excel files. Here we take `pandas` as an example to read and save Excel files (require installation of `xlrd/xlwt` package, `pip install xlrd==1.2.0 xlwt`):

```sql
-- Save the above sample_data as an Excel file

!python env "PYTHON_ENV=source activate dev";
!python conf "schema=st(field(file,binary))";
!python conf "dataMode=model";
!python conf "runIn=driver";
run command as Ray.`` where
inputTable="sample_data"
and outputTable="excel_data"
and code='''
import io
import ray
import pandas as pd
from pyjava.api.mlsql import RayContext, PythonContext

ray_context = RayContext.connect(globals(), None)

data = ray_context.to_pandas()

output = io.BytesIO()
writer = pd.ExcelWriter(output, engine='xlwt')
data.to_excel(writer, index=False)
writer.save()
xlsx_data = output.getvalue()

context.build_result([{"file":xlsx_data}])
''';
!saveFile _ -i excel_data -o /tmp/sample_data.xlsx;
```

```sql
-- Read sample_data.xlsx file

load binaryFile.`/tmp/sample_data.xlsx` as excel_table;

!python env "PYTHON_ENV=source activate dev";
!python conf "schema=st(field(a,double),field(b,double))";
!python conf "dataMode=model";
!python conf "runIn=driver";
run command as Ray.`` where
inputTable="excel_table"
and outputTable="excel_data"
and code='''
import io
import ray
from pyjava.api.mlsql import RayContext
import pandas as pd

ray_context = RayContext.connect(globals(),None)

file_content = ray_context.to_pandas().loc[0, "content"]

df = pd.read_excel(io.BytesIO(file_content))
data = [row for row in df.to_dict('records')]
context.log_client.log_to_driver(data)
context.build_result(data)
''';
```

## Byzer-python distributed computing

Distributed processing depends on Ray environment. For building Ray cluster, see [Environment denpendence](/byzer-lang/en-us/python/env.md). Here we briefly introduce how to use Pyjava advanced API and Ray to complete distributed computing:

```sql
!python env "PYTHON_ENV=source activate dev";
!python conf "schema=st(field(_id,string),field(x,double),field(y,double))";
!python conf "dataMode=model";
!python conf "runIn=driver";

run command as Ray.`` where
inputTable="sample_data"
and outputTable="python_output_table"
and code='''
import ray
from pyjava import rayfix
from pyjava.api.mlsql import RayContext
import socket

## To get ray_context you need to use Ray here and in the second parameter you need to fill in the address and port of Ray head-node
ray_context = RayContext.connect(globals(), '10.1.3.197:10001')

## Ray cluster distributed processing
@ray.remote
@rayfix.last
def handle_record(servers):

    datas = RayContext.collect_from(servers)

    result = []
    for row in datas:
        item = {"_id": socket.gethostname()}
        item["x"] = row["a"]
        item["y"] = row["b"]
        result.append(item)
    return result

data_servers = ray_context.data_servers()
res = ray.get(handle_record.remote(data_servers))
## Build result data return
context.build_result(res)
''';
```

<p align="center">
<img height="400" src="/byzer-lang/en-us/python/image/image-etl-ray.png" title="image-etl-ray"/>
</p>


## Byzer-python charting

You can use Python plotting packages (`matplotlib`, `plotly`, `pyecharts`, etc., which need to be installed in advance) to draw diagrams in Byzer desktop and Bzyer Notebook and output images with API provided by Byzer-python:

```sql
-- Plot data
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
```

Use `pyecharts` to draw diagrams:

```sql
!python env "PYTHON_ENV=source activate dev";
!python conf "schema=st(field(content,string),field(mime,string))";
!python conf "dataMode=model";
!python conf "runIn=driver";

run command as Ray.`` where
inputTable="data"
and outputTable="plt"
and code='''
from pyjava.api.mlsql import RayContext,PythonContext
from pyecharts import options as opts
import os
from pyecharts.charts import Bar

ray_context = RayContext.connect(globals(),None)

data = ray_context.to_pandas()
data_a = data['Busn_A']
data_b = data['Busn_B']

# Basic histogram
bar = Bar()
bar.add_xaxis(["Shirt", "Sweater", "Tie", "Pants", "Hat", "Gloves", "Socks"])


bar.add_yaxis("Saler A", list(data_a))
bar.add_yaxis("Saler B", list(data_b))
bar.set_global_opts(title_opts=opts.TitleOpts(title="Sales Info"))
bar.render('bar_demo.html') # Generate html file
html = ""
with open("bar_demo.html") as file:
   html = "\n".join(file.readlines())
os.remove("bar_demo.html")
context.build_result([{"content":html,"mime":"html"}])
''';
```

<p align="center">
<img alt="image-plot" src="/byzer-lang/en-us/python/image/image-plot.png"/>
</p>


Use `matplotlib` to draw diagrams:

```sql
!python env "PYTHON_ENV=source activate dev";
!python conf "schema=st(field(content,string),field(mime,string))";
!python conf "dataMode=model";
!python conf "runIn=driver";

run command as Ray.`` where
inputTable="data"
and outputTable="plt"
and code='''
from pyjava.api.mlsql import RayContext,PythonContext
import matplotlib.pyplot as plt
import numpy as np
from pyjava.api import Utils
ray_context = RayContext.connect(globals(),None)

data = ray_context.to_pandas()


labels = ["Shirt", "Sweater", "Tie", "Pants", "Hat", "Gloves", "Socks"]
men_means = data['Busn_A']
women_means = data['Busn_B']

x = np.arange(len(labels)) # the label locations
width = 0.35 # the width of the bars

fig, ax = plt.subplots()
rects1 = ax.bar(x - width/2, men_means, width, label='Saler A')
rects2 = ax.bar(x + width/2, women_means, width, label='Saler B')

# Add some text for labels, title and custom x-axis tick labels, etc.
ax.set_ylabel('Sales')
ax.set_title('Sales Info')
ax.set_xticks(x)
ax.set_xticklabels(labels)
ax.legend()


def autolabel(rects):
    """Attach a text label above each bar in *rects*, displaying its height."""
    for rect in rects:
        height = rect.get_height()
        ax.annotate('{}'.format(height),
                    xy=(rect.get_x() + rect.get_width() / 2, height),
                    xytext=(0, 3),  # 3 points vertical offset
                    textcoords="offset points",
                    ha='center', va='bottom')


autolabel(rects1)
autolabel(rects2)

fig.tight_layout()

Utils.show_plt(plt, context)
''';
```

<p align="center">
<img alt="image-plot2" src="/byzer-lang/en-us/python/image/image-plot2.png"/>
</p>