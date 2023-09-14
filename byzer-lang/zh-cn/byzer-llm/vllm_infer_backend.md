# 使用 vllm 作为 inference backend

Byzer-LLM 其实支持 Transformers, vLLM, Deepspeed Inference， Aviary/TGI 等多种backend。 这篇文章我们介绍
如何在 Byzer-LLM 中使用 vLLM 作为推理后端。

已经通过实机测试模型(会持续更新)：

1. falcon 系列
2. llama/llama2 以及衍生系列 
3. baichuan2

## 如何使用 vLLM 启动模型

```sql
!byzerllm setup single;
!byzerllm setup "num_gpus=8";
!byzerllm setup "infer_backend=ray/vllm";

-- include http.`project.LLMs.clear_nodes`;

run command as LLM.`` where 
action="infer"
and localModelDir="/home/byzerllm/models/f40-dog-trans-lr3-chat-lr1.5/"
and pretrainedModelType="custom/auto"
and udfName="vllm_falcon_40b_chat"
and modelTable="command";
```

相比 Transformers 作为 bakcend， 如果想切换使用 vLLM  作为 backend,需要调整两个参数：

1. 需要显示用 `!byzerllm`  指定推理后端。
2. `pretrainedModelType` 固定设置为 `custom/auto`, 也就是让 backend 自己自动设置模型类型。

注意：vllm 切分模型是根据模型里的 heads 数来确定的，比如 num_gpus=8, 那么 8 需要能够被 heads 整除。不同模型 heads 不相同，可以根据
模型的 heads 数来调整 num_gpus 的值，或者根据报错修改该值。

## 一些性能参考

以 Falcon 40B 为例，在输入 2-4k tokens的情况下， latency 在5-15s 之间，八卡 3090 token 生成速度可以稳定在  20-25之间每秒，理论上 QPS 也会提升比较明显。