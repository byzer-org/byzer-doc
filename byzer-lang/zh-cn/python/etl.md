# 数据处理

先构建一组测试数据，用以后续演示。

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

保存至数据湖：

```sql
save overwrite data as delta.`example.mock_data`;
```

加载数据湖里的 `mock_data`，并做简单的处理，得到 `sample_data`。

```sql
load delta.`example.mock_data` as example_data;
select features[0] as a ,features[1] as b from example_data
as sample_data;
```

## Byzer-python 处理数据

如果想在虚拟环境中运行 Byzer-python 代码，那么可以用下面的指令指定需要使用的 Python 虚拟环境:

```sql
!python env "PYTHON_ENV=source activate dev";
```

> 1. `source activate dev`  可以替换成绝对路径 `source /path/to/activate dev`。
>
> 2. 如果没有虚拟环境，配置为 `"PYTHON_ENV=:"` 即可。

接着指定代码是在 Driver 还是在 Executor 端执行，推荐在 Driver 执行：

```sql
!python conf "runIn=driver";
```

如果代码中使用了 `RayContext.foreach` 或 `RayContext.map_iter`，请将 `dataMode` 设置为 `data`，否则设置为 `model`。 在这个例子里，我们设置为 `model`：

```sql
!python conf "dataMode=model";
```

现在指定 Python 脚本返回的数据格式：如果返回的是表，可以通过设置 `schema=st(field({name},{type})...)` 定义各字段的字段名和字段类型；如果返回到是文件，可设置 `schema=file`。

```sql
!python conf "schema=st(field(_id,string),field(x,double),field(y,double))";
```

`schema` 字段类型对应关系：

| Python 类型 | schema 字段类型 | 例（Python 数据：schema 定义）                                                                                              |
|----------| --------------- |---------------------------------------------------------------------------------------------------------------------|
| `int`      | `long`            | `{"int_value": 1}` ：`"schema=st(field(int_value,long))"`                                                            |
| `float`    | `double`          | `{"float_value": 2.1}` ：`"schema=st(field(float_value,double))"`                                                    |
| `str`      | `string`          | `{"str_value": "Everything is a table!"}` ：`"schema=st(field(str_value,string))"`                               |
| `bool`     | `boolean`         | `{"bool_value": True}` ：`"schema=st(field(bool_value,boolean)"`                                                     |
| `list`    | `array`           | `{"list_value": [1.0, 3.0, 5.0]}`：`"schema=st(field(list_value,array(double)))"`                                    |
| `dict`    | `map`             | `{"dict_value": {"list1": [1, 3, 5], "list2": [2, 4, 6]}}` ：`"schema=st(field(dict_value,map(string,array(long))))"` |
| `bytes` | `binary` | `{"bytes_value": b"Everything is a table!"}` ：`"schema=st(field(bytes_value,binary))"` |

> 要注意的是，在schema的类型中，整型需要使用long，而不是integer或short；浮点数需要使用double，而不是float。因为在python中，int和float都是8个字节的。

以上四项配置都是 Session 级别的，推荐每次执行 Python 脚本时手动指定。

运行 Python 脚本对表 `sample_data` 进行处理：

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
<img src="/byzer-lang/zh-cn/python/image/image-etl-1.png" title="image-etl-1" height="400"/>
</p>

## Byzer-python 代码说明

注意到 Python 脚本以字符串参数形式出现在代码中，这是 Byzer-Python 代码的一个模版。其中参数 `inputTable` 指定需要处理的表，没有需要处理的表时，可设置为 `command`
；参数 `outputTable` 指定输出表的表名；参数 `code` 为需要执行的 Python 脚本。

```sql
run command as Ray.`` where 
inputTable="sample_data"
and outputTable="python_output_table"
and code='''
import ray
......
''';
```

传入的 Python 脚本：

```python
## 引入必要的包
import ray
from pyjava.api.mlsql import RayContext

## 获取 ray_context，如果需要使用 Ray 集群，那么第二个参数填写集群 Master 节点的地址
## 否则设置为None就好。
ray_context = RayContext.connect(globals(), None)

# 通过ray_context.data_servers() 获取所有数据源，如果开启了Ray，那么就可以
# 分布式获取这些数据进行处理。
datas = RayContext.collect_from(ray_context.data_servers())
id_count = 1

## 从 java 端接受的数据格式也是list(dict)，也就是说，每一行的数据都以字典的数据结构存储。
## 比如 sample_data 的数据，在 Python 端拿到的结构就是
## [{'a':'5.1','b':'3.5'}, {'a':'5.1','b':'3.5'}, {'a':'5.1','b':'3.5'} ...] 
## 基于这个数据结构，我们对输入数据进行数据处理
def handle_record(row):
    global id_count
    item = {"_id": str(id_count)}
    id_count += 1
    item["x"] = row["a"]
    item["y"] = row["b"]
    return item

result = map(handle_record, datas)

## 此处 result 是一个迭代器，context.build_result 也支持传入生成器/数组
context.build_result(result)
```

上文的 Byzer-python 代码是用原生的 Byzer-lang 代码书写的。在 Byzer Notebook 和 Byzer 桌面版中，您可以使用**注解**来配置上文提到的 `!python`
配置项和输入输出表 `inputTable/outputtable` ，此时 Byzer-python 代码的编写和与普通 Python 脚本无异：

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

## Byzer-python 读写 Excel 文件

Python 有很多处理 Excel 文件的库，功能成熟完善，您可以在 Byzer-python 环境中安装相应的库来处理您的 Excel 文件。这里以 `pandas` 为例来读取和保存 Excel 文件（需要安装 `xlrd/xlwt`
包，`pip install xlrd==1.2.0 xlwt`）：

```sql
-- 将上文 sample_data 保存成 Excel 文件

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
-- 读取 sample_data.xlsx 文件

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

## Byzer-python 分布式计算

分布式处理依赖 Ray 环境，您可以参考[Ray 环境搭建](/byzer-lang/zh-cn/python/env.md) 搭建 Ray 集群。这里我们简单介绍下如何使用 Pyjava 高阶 API 使用 Ray 完成分布式计算：

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

## 获取 ray_context,这里需要使用 Ray，第二个参数填写 Ray head-node 的地址和端口
ray_context = RayContext.connect(globals(), '10.1.3.197:10001')

## Ray 集群分布式处理
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
res =  ray.get(handle_record.remote(data_servers))
## 构造结果数据返回
context.build_result(res)
''';
```

<p align="center">
<img height="400" src="/byzer-lang/zh-cn/python/image/image-etl-ray.png" title="image-etl-ray"/>
</p>

## Byzer-python 图表绘制

您可以在 Byzer 桌面版 和 Bzyer Notebook 中使用 Python 绘图包（`matplotlib`、`plotly`、`pyecharts` 等，需要提前安装）绘制精美的图表，并用 Byzer-python 提供的
API 输出图片：

```sql
-- 绘图数据
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

使用 `pyecharts` 绘制图表：

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

# 基本柱状图
bar = Bar()
bar.add_xaxis(["Shirt", "Sweater", "Tie", "Pants", "Hat", "Gloves", "Socks"])


bar.add_yaxis("Saler A", list(data_a))
bar.add_yaxis("Saler B", list(data_b))
bar.set_global_opts(title_opts=opts.TitleOpts(title="Sales Info"))
bar.render('bar_demo.html')  # 生成html文件
html = ""
with open("bar_demo.html") as file:
   html = "\n".join(file.readlines())
os.remove("bar_demo.html")
context.build_result([{"content":html,"mime":"html"}])
''';
```

<p align="center">
<img alt="image-plot" src="/byzer-lang/zh-cn/python/image/image-plot.png"/>
</p>

使用 `matplotlib` 绘制图表：

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

x = np.arange(len(labels))  # the label locations
width = 0.35  # the width of the bars

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
<img alt="image-plot2" src="/byzer-lang/zh-cn/python/image/image-plot2.png"/>
</p>