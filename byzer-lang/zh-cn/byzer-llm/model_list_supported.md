# Byzer-LLM 内置大模型支持列表

> 截止到：2023-07-01

Byzer-LLM 目前支持两类大模型：

1. 私有大模型。用户需要自己下载模型权重，在启动模型时指定路径。
2. SaaS大模型。 用户需要提供token

两者的部署和使用方式完全一致，区别在于私有大模型需要占用较大资源（诸如GPU/CPU等）。 SaaS大模型启动都是Proxy worker,本身不会占用什么资源。


## 开源大模型

下面参数名称作为 `pretrainedModelType` 可选参数列表。

| Parameter | Description |
|--|--|
|bark| 语音合成模型 |
|whisper| fast-whisper,语音转文字模型 |
|chatglm6b| 语言大模型  |
|custom/chatglm2| chatglm6b 的2代版本 |
|moss|  语言大模型 |
|custom/alpha_moss|  支持多卡部署版本的 Moss |
|dolly|  语言大模型 |
|falcon| 语言大模型  |
|llama|  语言大模型(llama架构的模型都可以用这个，比如vicuna等) |
|custom/starcode|代码补全|
|custom/visualglm|  多模态6B模型 |
|custom/m3e|  embedding 模型，地址：https://huggingface.co/moka-ai/m3e-base |
|custom/baichuan|  语言大模型 |

另外 vLLM 支持模型的模型我们也都支持。


## SaaS 大模型

| Parameter | Description |
|--|--|
|saas/chatglm|  Chatglm130B |
|saas/sparkdesk|  星火大模型 |
|saas/baichuan|  百川大模型 |
|saas/zhipu|  智谱大模型 |
| saas/minimax   | MiniMax 大模型 |
| saas/qianfan   | 文心一言        |

## 能力说明

大部分语言大模型都对外提供两种接口：

1. embedding
2. chat


只提供语言生成的模型：

1. saas/chatglm
2. saas/sparkdesk

只提供 embedding 服务的模型：

1. custom/m3e

