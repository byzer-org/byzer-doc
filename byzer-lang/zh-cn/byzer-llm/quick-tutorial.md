# Byzer-LLM 快速使用指南

该文档将会带领你快速了解 Byzer-LLM 的安装和使用。

## 安装

参考文档：https://docs.byzer.org/#/byzer-lang/zh-cn/byzer-llm/deploy 

注意，即使你已经有安装过大模型相关的环境，建议你依然使用`裸机全自动化部署`, Byzer LLM 会创新一个 byzerllm 用户，该用户的环境变量和配置文件都是独立的，不会影响到你的其他环境。

一旦安装好环境之后，就可以通过 `http://127.0.0.1:9002` 访问 Byzer Notebook 了。

## 使用

### 1. 下载模型

这里推荐根据资源情况，你可以选择不同大小的模型。假设你下载了 OpenBuddy 社区的 llama7b : https://huggingface.co/OpenBuddy/openbuddy-llama-7b-v4-fp16 ，你可以将其放入:

```
/home/byzerllm/models/openbuddy-llama-7b-v4-fp16
```

### 2. 启动模型

新建一个 Notebook, 在第一个cell里填入如下代码：

```sql
!byzerllm setup single;
!byzerllm setup "num_gpus=1";
!byzerllm setup "maxConcurrency=1";

run command as LLM.`` where 
action="infer"
and pretrainedModelType="llama"
and localModelDir="/home/byzerllm/models/openbuddy-llama-7b-v4-fp16"
and reconnect="false"
and udfName="llama_7b_chat"
and modelTable="command";
```

你可以参考这篇文章访问 Ray Dashboard, 从而在 Web 界面上查看日志等。

https://docs.byzer.org/#/byzer-lang/zh-cn/byzer-llm/ray

### 和大模型对话

执行完成上面的代码后，你就可以在第二个cell里输入你的对话了。

```sql
--%chat
--%model=llama_7b_chat
--%system_msg=You are a helpful assistant. Think it over and answer the user question correctly.
--%user_role=User
--%assistant_role=Assistant
--%output=q1

你好，请记住我的名字，我叫祝威廉。如果记住了，请说记住。
```

接着你试试他记住了不：

```sql
--%chat
--%model=llama_7b_chat
--%user_role=User
--%assistant_role=Assistant
--%input=q1
--%output=q2

请问我叫什么名字？
```

### 3. 通过SQL调用大模型

你也可以通过SQL来调用：

```sql
select 
llama_7b_chat(llm_param(map(
              "user_role","User",
              "assistant_role","Assistant",
              "system_msg",'You are a helpful assistant. Think it over and answer the user question correctly.',
              "instruction",llm_prompt('
你好，请记住我的名字：{0}              
',array("祝威廉"))

)))

 as q as q1;

```

继续追问：

```sql
select 
llama_7b_chat(llm_stack(q,llm_param(map(
              "user_role","User",
              "assistant_role","Assistant",
              "instruction",'请问我是谁？'
))))

as q from q1
as q2;
```

### 4. 通过Python调用大模型

```python
#%python
#%input=command
#%output=output
#%schema=st(field(content,string))
#%runIn=driver
#%dataMode=model
#%cache=false
#%env=:

from pyjava import RayContext
import requests
from typing import List, Tuple
import json

ray_context = RayContext.connect(globals(),None)

def request(sql:str,json_data:str)->str:
    url = "http://127.0.0.1:9003/model/predict"
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
    newhis = [{"query":item[0],"response":item[1]} for item in history]
    json_data = json.dumps([
        {"instruction":s,"history":newhis}
    ])
    
    response = request("select llama_7b_chat(array(feature)) as value",json_data)   


    t = json.loads(response)
    t2 = json.loads(t[0]["value"][0])
    return t2[0]["predict"] 
    
ray_context.build_result([{"content":chat("You are a helpful assistant. Think it over and answer the user question correctly. User:你好\nAssistant:",[])}])

```

### 5. 对大模型做微调

可以参考这篇文章：https://docs.byzer.org/#/byzer-lang/zh-cn/byzer-llm/model-sft

### 6. 对大模型做二次预训练

可以参考这篇文章：https://docs.byzer.org/#/byzer-lang/zh-cn/byzer-llm/model-sfft

