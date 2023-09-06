# 使用 Deepspeed 作为 inferrence backend

Byzer-LLM 其实支持 Transformers, vLLM, Deepspeed Inference， Aviary/TGI 等多种backend。 这篇文章我们介绍
如何在 Byzer-LLM 中使用 Deepspeed 作为推理后端。

已经通过实机测试模型(会持续更新)：

1. llama 以及衍生系列 

## 如何使用 Deepspeed 启动模型

```sql
!byzerllm setup single;
!byzerllm setup "num_gpus=4";
!byzerllm setup "infer_backend=ray/deepspeed";

include http.`project.LLMs.clear_nodes`;

run command as LLM.`` where 
action="infer"
and localModelDir="/home/byzerllm/models/llama-30b-cn/"
and pretrainedModelType="custom/auto"
and udfName="deepspeed_chat"
and reconnect="false"
and modelTable="command";
```

相比 Transformers 作为 bakcend， 如果想切换使用 Deepspeed  作为 backend,需要调整两个参数：

1. 需要显示用 `!byzerllm`  指定推理后端。
2. `pretrainedModelType` 固定设置为 `custom/auto`, 也就是让 backend 自己自动设置模型类型。


## 一些限制说明

Deepspeed 加载模型对内存要求极高，这也导致加载很慢， `num_gpus`  设置的越高，需要的临时内存就越多，内存不足会导致模型加载失败。
譬如加载 30B 的 llama 模型，如果 num_gpus 设置为 8， 那么 1T 内存都不够。 num_gpus设置为 4， 大概最高峰需要占用 600G 内存。
加载时间大约需要 5-10分钟。

此外 Deepspeed 需要有C++编译器：

Centos 8 可以按如下方式安装：

```
sudo dnf install gcc-c++
```

Ubuntu  则可以这样安装：

```
sudo apt-get install bu
```

## 一些性能说明

Deepspeed 的推理性能 latency, 大约可以达到 Transformers 的 1/3 左右，甚至更少。