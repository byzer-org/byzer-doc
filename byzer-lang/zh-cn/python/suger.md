# Byzer-python 工具语法糖

为了方便用户编写 Byzer-python 代码，我们在 Byzer-Notebook, Byzer Desktop 
等产品中提供了如下的方式来写 Python代码：

```python
#%python
#%input=command
#%output=test
#%schema=st(field(response,string))
#%runIn=driver
#%dataMode=model
#%cache=false
#%env=source /home/winubuntu/miniconda3/bin/activate byzerllm-desktop
#%pythonExec=/home/winubuntu/miniconda3/envs/byzerllm-desktop/bin/python

 import ray
from pyjava.api.mlsql import RayContext,PythonContext
from pyjava.storage import streaming_tar
from pyjava import rayfix
import os
import json
import logging
import sys

from byzerllm.moss.models.modeling_moss import MossForCausalLM
from byzerllm.moss.moss_inference import Inference    

ray_context = RayContext.connect(globals(),"127.0.0.1:10001")

@ray.remote(num_gpus=1)
class Test():
    def __init__(self):
        pass
    
    def test(self):        
        os.environ["CUDA_VISIBLE_DEVICES"] = "0"
        
        # Create an Inference instance with the specified model directory.
        print("init model")
        model = MossForCausalLM.from_pretrained("/home/winubuntu/projects/moss-model/moss-moon-003-sft-plugin-int4").half().cuda()
        print("infer")
        infer = Inference(model, device_map="auto")
        # Define a test case string.
        test_case = "<|Human|>: 你好 MOSS<eoh>\n<|MOSS|>:"
        
        # Generate a response using the Inference instance.
        res = infer(test_case)
        print(res)
        # Print the generated response.
        return res
        
res = ray.get(Test.remote().test.remote())
ray_context.build_result([{"response":res[0]}])
```

在上面代码中， 这些工具会提供语法糖，自动将 `#%` 注释 改写成 `!python conf ` 设置，并且生成 `run command as Ray` 语法。

此外，Byzer-Notebook 不需要自己手写这些注释，当你将Cell设置为 Python 代码时，会提供一个表格框方便你填写注释。

注意：Byzer Notebook 暂时不能识别 `pythonExec` 参数，你需要使用 `env` 来设置。为了确保正确，你可以两个注释都填写上，就像上面的示例展示的那样。