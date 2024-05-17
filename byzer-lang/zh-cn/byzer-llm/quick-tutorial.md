# Byzer-SQL 大模型快速使用指南

该文档将会带领你快速了解 Byzerd-SQL 用。

## 安装 Byzer 数据库

参考文档：https://docs.byzer.org/#/byzer-lang/zh-cn/byzer-llm/deploy 

注意，即使你已经有安装过大模型相关的环境，建议你依然使用`裸机全自动化部署`, Byzer LLM 会创新一个 byzerllm 用户，该用户的环境变量和配置文件都是独立的，不会影响到你的其他环境。

一旦安装好环境之后，就可以通过 `http://127.0.0.1:9002` 访问 Byzer Notebook 了。

## 使用

在 Byzer 数据库所在服务器上，用如下指令启动一个SaaS大模型代理：

```bash
byzerllm deploy --pretrained_model_type saas/qianwen \
--cpus_per_worker 0.001 \
--gpus_per_worker 0 \
--num_workers 2 \
--infer_params saas.api_key=${MODEL_QIANWEN_TOKEN}  saas.model=qwen-max \
--model qianwen_chat
```

这里记得把你的 `${MODEL_QIANWEN_TOKEN}` 替换成你的实际 API_KEY.

你可以用相同的方式部署一个私有模型：

```bash
byzerllm deploy --pretrained_model_type custom/auto \
--infer_backend vllm \
--model_path /home/winubuntu/models/openbuddy-zephyr-7b-v14.1 \
--cpus_per_worker 0.001 \
--gpus_per_worker 1 \
--num_workers 1 \
--infer_params backend.max_model_len=28000 \
--model zephyr_7b_chat
```

更多信息参考文档: https://github.com/allwefantasy/byzer-llm

### 2. 连接模型

在你的账户下，新建一个 Notebook, 在第一个cell里填入如下代码：

```sql
-- 连接一个已经部署好的模型
!byzerllm setup single;

run command as LLM.`` where 
action="infer"
and reconnect="true"
and pretrainedModelType="saas/*"
and udfName="qianwen_chat";
```

这里我们连接了在命令行中启动的 qianwen_chat 实例。

### 和大模型对话

执行完成上面的代码后，你就可以在第二个cell里输入你的对话了。

```sql
--%chat
--%model=qianwen_chat
--%output=q1

你好，请记住我的名字，我叫祝威廉。如果记住了，请说记住。
```

接着你试试他记住了不：

```sql
--%chat
--%model=qianwen_chat
--%input=q1
--%output=q2

请问我叫什么名字？
```

输出：

```
您好，您叫祝威廉。
```

### 3. 通过SQL调用大模型

你也可以通过SQL来调用：

```sql
select 
kimi_chat(llm_param(map(
              "instruction",'我是威廉，请记住我是谁。'
)))

as response as table1;

select llm_result(response) as result from table1 as output;
```

继续追问：

```sql
select 
kimi_chat(llm_stack(response,llm_param(map(
              "instruction",'请问我是谁？'
))))

as response from table1
as table2;

select llm_result(response) as result from table2 as output;
```


### 4. 通过Python调用大模型

打开一个新的Cell,复制黏贴下面的代码到Cell中：

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
    
ray_context.build_result([{"content":chat("你好",[])}])


```



### 5. 对大模型做微调

可以参考这篇文章：https://docs.byzer.org/#/byzer-lang/zh-cn/byzer-llm/model-sft

### 6. 对大模型做二次预训练

可以参考这篇文章：https://docs.byzer.org/#/byzer-lang/zh-cn/byzer-llm/model-sfft

