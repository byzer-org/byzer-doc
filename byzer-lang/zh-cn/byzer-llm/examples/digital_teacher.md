# 虚拟外教

构建一个虚拟外教，会涉及到三个大模型：

1. 语音转文本
2. 大预言模型
3. 文本合成语音

我们分别使用：

1. fast whisper
2. chatglm6b
3. bark

> 在继续后面的步骤之前，请确保按官方文档部署好环境。


### 部署 Fast Whisper

模型下载地址： https://huggingface.co/guillaumekln/faster-whisper-large-v2。需要提前下载到 Ray 所在服务器

1. 进入 /home/byzerllm/miniconda3/envs/byzerllm-dev/lib 目录下，并且做一个软链（如果你用Byzer 提供的setup_machine脚本，应该会自动有这个软链）

```
cd /home/byzerllm/miniconda3/envs/byzerllm-dev
ln -s lib lib64
```
2. 因为该模型为了追求速度，所以依赖 NVIDIA libraries cuBLAS 11.x 和 cuDNN 8.x 。 请到 https://developer.nvidia.com/cudnn 下载，并且按照对应的安装步骤
将一些依赖库拷贝到前面我们创建的软链目录下。

3. 该模型一些依赖 Byzer-llm 默认是不带的，所以需要手动安装：

```
pip install fast-whisper
```


最后在 Byzer Notebook里启动：


```sql
!byzerllm setup "num_gpus=1";
!byzerllm setup single;
!byzerllm setup "resource.master=0.01";

run command as LLM.`` where 
action="infer"
and pretrainedModelType="whisper"
and localPathPrefix="/home/byzerllm/jobs"
and localModelDir="/home/byzerllm/models/faster-whisper-large-v2"
and modelWaitServerReadyTimeout="300"
and udfName="voice_to_text"
and reconnect="false"
and modelTable="command";
```

### 部署ChatGLM6B
这边我们可以使用任何byzer的用于chat模型llama和chagglm都可以, 注意下面的python文件中，需要把udf换成我们现在启动的聊天的udf。
```sql
!byzerllm setup single;
!byzerllm setup "num_gpus=2";
!byzerllm setup "resources.master=0.001";

run command as LLM.`` where 
action="infer"
and pretrainedModelType="llama"
and localModelDir="/home/byzerllm/models/openbuddy-llama-13b-v5-fp16"
and reconnect="false"
and udfName="llama_13b_chat"
and modelTable="command";
```

### 部署 Bark 

模型请到 https://huggingface.co/suno/bark 下载。需要提前下载到 Ray 所在服务器

下载完模型，进入模型目录，然后执行如下指令：

```
git clone https://huggingface.co/bert-base-multilingual-cased  pretrained_tokenizer
```

注意，该模型在运行时还会下载一些音频的编解码器，所以需要确保网络通畅。

```sql
!byzerllm setup single;
!byzerllm setup "num_gpus=1";
--!byzerllm setup "resource.master=0.01";
--!byzerllm setup "resource.worker_2=0";
!byzerllm setup "maxConcurrency=4";

run command as LLM.`` where 
action="infer"
and pretrainedModelType="bark"
and localPathPrefix="/home/byzerllm/jobs"
and localModelDir="/home/byzerllm/models/bark"
and modelWaitServerReadyTimeout="300"
and udfName="text_to_voice"
and reconnect="false"
and modelTable="command";
```

### 注意

如果你显卡有限，比如只有一张显卡，但是显存够大，那么你可以通过 `num_gpus` 来控制每个模型可以使用的显卡资源数。


```sql
!byzerllm setup single;
!byzerllm setup "num_gpus=0.3";
```

在这里，我们使用 num_gpus=0.3 表示他只会占用0.5颗GPU, 如果部署每个模型的时候，设置这个参数，那么就会部署在一块GPU上。
不过你需要自己确保这块GPU的显存确实可以同时跑多个模型。

### 开发一个界面

这里我们用gradio 开发一个界面,假设文件名称叫 digital_techer.py:

```python
import concurrent.futures
import json
import re
import time
from base64 import b64encode
from typing import List, Tuple

import gradio as gr
import numpy as np
import requests

# select finetune_model_predict(array(feature)) as a
def request(sql: str, json_data: str) -> str:
    url = 'http://127.0.0.1:9003/model/predict'
    data = {
        'sessionPerUser': 'true',
        'sessionPerRequest': 'true',
        'owner': 'william',
        'dataType': 'string',
        'sql': sql,
        'data': json_data
    }
    response = requests.post(url, data=data)
    if response.status_code != 200:
        raise Exception(response.text)
    return response.text


def voice_to_text(rate: int, t: np.ndarray) -> str:
    json_data = json.dumps([
        {"rate": rate, "voice": t.tolist()}
    ])

    response = request('''
     select voice_to_text(array(feature)) as value
    ''', json_data)

    t = json.loads(response)
    t2 = json.loads(t[0]["value"][0])
    return t2[0]["predict"]

def text_to_voice(sequence) -> np.ndarray:
    json_data = json.dumps([
        {"instruction": sequence}
    ])
    data = request('''
                 select text_to_voice(array(feature)) as value
                ''', json_data)
    t = json.loads(data)
    t2 = json.loads(t[0]["value"][0])
    return np.array(t2[0]["predict"])

def execute_parallel(fn,a,num_workers=3):
    import concurrent.futures

    def process_chunk(chunk):
        return [fn(*m) for m in chunk]

    def split_list(lst, n):
        k, m = divmod(len(lst), n)
        return [lst[i * k + min(i, m):(i + 1) * k + min(i + 1, m)] for i in range(n)]

    # Split the list into three chunks
    chunks = split_list(a,num_workers)

    with concurrent.futures.ThreadPoolExecutor(max_workers=num_workers) as executor:
        results = list(executor.map(lambda x: process_chunk(x), chunks))
    return results

## s,history = state.history
def chat(s: str, history: List[Tuple[str, str]]) -> str:
    newhis = [{"role": item[0], "content": item[1]} for item in history]
    template = """You are a helpful assistant. Think it over and answer the user question correctly. 
    User: {context}
    Please answer based on the content above: 
    {query}
    Assistant:"""
    json_data = json.dumps([
        {"instruction": s, "k": 1, "temperature": 0.1, "prompt": template, 'history': newhis, 'max_length': 8000}
    ])
    response = request('''
     select llama_13b_chat(array(feature)) as value
    ''', json_data)
    t = json.loads(response)
    t2 = json.loads(t[0]["value"][0])
    return t2[0]["predict"]


class UserState:
    def __init__(self, history: List[Tuple[str, str]] = [], output_state: str = "") -> None:
        self.history = history
        self.output_state = output_state

    def add_chat(self, role, content):
        self.history.append((role, content))
        if len(self.history) > 10:
            self.history = self.history[len(self.history) - 10:]

    def add_output(self, message):
        self.output_state = f"{self.output_state}\n\n{message}"

    def clear(self):
        self.history = []
        self.output_state = ""


def talk(t: str, state: UserState) -> str:
    state.add_chat('user', t)
    s = chat(t, history=state.history)
    state.add_chat('assistant', s)
    return s


def html_audio_autoplay(bytes: bytes) -> object:
    """Creates html object for autoplaying audio at gradio app.
    Args:
        bytes (bytes): audio bytes
    Returns:
        object: html object that provides audio autoplaying
    """
    b64 = b64encode(bytes).decode()
    html = f"""
    <audio controls autoplay>
    <source src="data:audio/wav;base64,{b64}" type="audio/wav">
    </audio>
    """
    return html


def convert_to_16_bit_wav(data):
    # Based on: https://docs.scipy.org/doc/scipy/reference/generated/scipy.io.wavfile.write.html
    warning = "Trying to convert audio automatically from {} to 16-bit int format."
    if data.dtype in [np.float64, np.float32, np.float16]:
        data = data / np.abs(data).max()
        data = data * 32767
        data = data.astype(np.int16)
    elif data.dtype == np.int32:
        data = data / 65538
        data = data.astype(np.int16)
    elif data.dtype == np.int16:
        pass
    elif data.dtype == np.uint16:
        data = data - 32768
        data = data.astype(np.int16)
    elif data.dtype == np.uint8:
        data = data * 257 - 32768
        data = data.astype(np.int16)
    else:
        raise ValueError(
            "Audio data cannot be converted automatically from "
            f"{data.dtype} to 16-bit int format."
        )
    return data


def main_note(audio, text, state: UserState):
    if audio is None:
        return "", state.output_state, state

    if len(state.history) == 0:
        state.history.append(["system", "You are a helpful assistant."])

    rate, y = audio
    print("voice to text:")

    t = voice_to_text(rate, y)

    if len(t.strip()) == 0:
        return "", state.output_state, state

    if t.strip() == "重新开始":
        state.clear()
        return "", state.output_state, state

    print(t)
    print("talk to llama30b:")
    s = talk(t + " " + text, state)
    print("llama30b:", s)
    print("text to voice")
    message = f"你: {t}\n\n外教: {s}\n"
    sequences = re.split(r'[.!?。!?]', s)
    chunks = []
    start_time = time.time()
    for s in sequences:
        if len(s.strip()) == 0:
            continue
        chunks.append(s.strip())
    with concurrent.futures.ThreadPoolExecutor(max_workers=4) as executor:
        m = list(executor.map(lambda x: text_to_voice(x), chunks))
    m = np.concatenate(m)
    end_time = time.time()
    print(f"total time: {end_time - start_time} seconds")

    from scipy.io.wavfile import write as write_wav
    import io
    wav_file = io.BytesIO()
    write_wav(wav_file, 24_000, convert_to_16_bit_wav(m))
    wav_file.seek(0)
    html = html_audio_autoplay(wav_file.getvalue())

    state.add_output(message)
    return html, state.output_state, state

def main():
    state = gr.State(UserState())
    demo = gr.Interface(
        fn=main_note,
        inputs=[gr.Audio(source="microphone"), gr.TextArea(lines=30, placeholder="message"), state],
        outputs=["html", gr.TextArea(lines=30, placeholder="message"), state],
        examples=[
        ],
        interpretation=None,
        allow_flagging="never",
    )
    demo.launch(server_name="127.0.0.1", server_port=7861, debug=True)

if __name__ == "__main__":
    main()
```

之后运行命令

```
python digital_python.py
```

即可。
