# Byzer-python参数详解

在前面的示例中，你会看到类似这样的配置：

```sql
!python conf "pythonExec=/home/winubuntu/miniconda3/envs/byzerllm-desktop/bin/python";
!python conf "schema=st(field(ProductName,string),field(SubProduct,string))";
!python conf "dataMode=data";
!python conf "runIn=driver";
```

这些配置决定了后续 Python 代码的执行模式。 比如 pythonExec 其实是指定 Python 代码在什么环境下执行。
schema 则决定了 Python的输出表的格式是什么。 

## Byzer-python 常见参数：

| Parameter | Description |
|--|--|
|pythonExec| 指定  Python 虚拟环境的可执行入口 |
|schema| 指定 Python 代码执行后构建的表的 Schema |
|dataMode| 是否需要从Ray分布式回传数据给 Byzer 引擎,默认不是，所以设置为 `model` 即可。但是如果你使用了 RayContext.foreach, RayContext.map_iter 则必须设置为 `data`  |
|runIn|  脚本运行在Byzer `driver` 还是 `executor` 节点。正常选择 driver 即可。 |
|cache|  Python产生的数据集是不是要缓存起来，方便多次使用。如果是，请设置为 true. |

## 仅仅和模型部署相关的参数
|rayAddress|  设置一个 Ray 地址。 该参数对于部署模型有效|
|num_gpus| 单个模型需要的GPU资源。该参数对于部署模型有效 |
|maxConcurrency| 部署的模型需要支持的并发。该参数对于部署模型有效 |
|standalone| 是不是只有一个模型节点。是的话设置为true,否则为false. 该参数对于部署模型有效 |


## Schema 表达

当我们使用 Python 代码创建新表输出的时候，需要手动指定 Schema. 有两种情况：

1. 如果返回的是数据，可以通过设置 `schema=st(field({name},{type})...)` 定义各字段的字段名和字段类型；
2. 如果返回到是文件，可设置 `schema=file`；

设置格式如下：

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

此外，也支持 json/MySQL Create table 格式的设置方式.

json 格式符合 Spark 格式，你可以通过

```
!desc TableName json; 
```
获取json格式示例。比如：

```json
{"type":"struct",
 "fields":[
        {"name":"source","type":"string","nullable":true,"metadata":{}},
        {"name":"page_content","type":"string","nullable":true,"metadata":{}}
    ]
}
```


