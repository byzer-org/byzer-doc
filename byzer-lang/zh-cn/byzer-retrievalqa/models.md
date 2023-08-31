# 准备模型

基于大模型的问答知识库第一步是需要启动两个模型服务：

1. 大语言模型
2. 向量模型

## 大语言模型

比如我们启动一个 llama-30b-cn 模型，这个模型是一个中文的大语言模型，可以用来做问答。

```sql
-- 交互模型我们选择llama-30b-cn的模型
!byzerllm setup single;
!byzerllm setup "num_gpus=5";
!byzerllm setup "maxConcurrency=1";

run command as LLM.`` where 
action="infer"
and pretrainedModelType="llama"
and localModelDir="/home/byzerllm/models/llama-30b-cn"
and reconnect="true"
and udfName="llama_30b_chat"
and modelTable="command";
```

接着我们启动一个向量模型，该模型输入为文本，输出为向量。

```sql
-- 选择m3e模型给astronvim官网做向量化
!byzerllm setup single;
!byzerllm setup "num_gpus=0.2";
!byzerllm setup "maxConcurrency=2";

-- 部署embedding服务
run command as LLM.`` where 
action="infer"
and pretrainedModelType="custom/m3e"
and localModelDir="/home/byzerllm/models/m3e-base"
and udfName="emb"
and reconnect="true"
and modelTable="command";
```

你可以选择其他的向量模型。

实际上，大部分大模型也可以同时作为向量模型，但是一般我们还是会使用独立的向量模型在于：

1. 语言大模型普遍 6B 参数起，生成速度慢，同时成本偏高。
2. 向量模型更有正对性，可以针对不同的业务场景进行优化。
