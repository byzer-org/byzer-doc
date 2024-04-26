## Byzer-LLM API 调用

Byzer-LLM  一旦完成模型部署，你将会得到一个函数，该函数可以应用于Byzer-lang中的 ETL, 流式计算等形态的任务中。
与此同时，Byzer-LLM 也暴露出一个 endpoint, 方便你通过 http 协议获得交互。

地址形式为：

```
http://127.0.0.1:9003/model/predict
```

我们以Python为例，调用方式如下：

```python
import requests

#%python
#%input=command
#%output=output
#%schema=st(field(content,string))
#%runIn=driver
#%dataMode=model
#%cache=false
#%env=:

import requests
from typing import List, Tuple
import json

def request(sql:str,json_data:str)->str:
    url = "http://localhost:7003/model/predict"
    data = {
        "sessionPerUser": "true",
        "sessionPerRequest": "true",
        "owner": "william",
        "dataType": "string",
        "sql": sql,
        "data": json_data
    }
    response = requests.post(url, data=data)
    if response.status_code != 200:
        raise Exception(response.text)
    return response.text

def chat(s:str,history:List[Tuple[str,str]])->str:
    json_data = json.dumps([
        {"instruction":s}
    ],ensure_ascii=False)
    
    response = request("select qianwen_chat(array(feature)) as value",json_data)   


    t = json.loads(response)
    t2 = json.loads(t[0]["value"][0])
    return t2["output"] 
    # return response
    
```

POST 请求参数介绍：


| Parameter          | Value      | Desc|
|--------------------|------------|------|
| sessionPerUser     | true       |用户隔离命名空间|
| sessionPerRequest  | true       |在用户隔离的基础上按请求隔离命名空间|
| owner              | william    |函数的所有者|
| dataType           | string     |设置为string即可|
| sql                | <sql>      |对 data 如何进行处理的 SQL 描述|
| data               | <json_data> |传递的数据。注意这两是json 字符串，而不是json结构|


其中 data 是 json 字符串结构如下：

| Parameter          | Value      | Desc|
|--------------------|------------|------|
| instruction     |        |用户当前发送的对话|
| history  | 数组        |历史会话，数组，里面的元数结构为 {"role":"","content":""} 结构。其中role值为： system/user/asssitant|
| top_p  | 0.95      | 设置越高，回答越固定 |
| temperature  | 0.1       | 设置越低，回答越固定|
| max_length  | 1024       | 总token长度限制|
| embedding  | false       | 是否切换为embedding请求，也就是帮你把文本转换为向量表示形式，一般QA数据库需要|

