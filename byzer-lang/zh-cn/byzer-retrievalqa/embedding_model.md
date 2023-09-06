# 向量模型

在 Byzer 中，大部分大语言模型都可以支持作为 embedding 模型，但是这些模型偏大，速度较慢以及占用过大的 GPU 资源。所以
我么也内置了两个专门的向量模型，分别是：

1. m3e
2. bge

## 启动和使用 m3e 向量模型 

```sql
!byzerllm setup single;
!byzerllm setup "num_gpus=0.5";
!byzerllm setup "maxConcurrency=2";

-- set node="master";
-- include http.`project.Libs.node`;

-- 部署embedding服务
run command as LLM.`` where 
action="infer"
and pretrainedModelType="custom/m3e"
and localModelDir="/home/byzerllm/models/m3e-base"
and udfName="emb"
and reconnect="false"
and modelTable="command";
```

之后你可以快速通过如下代码进行测试：

```sql
--%chat
--%model=emb
--%embedding=true
--%output=q1

测试文字
```

这里需要注意的是 我们需要添加一个参数 `embedding=true`, 这样可以开启 embedding 模式。最后输出是一个json 数字数组。

你也可以在 SQL 中调用：

```sql

select llm_response_predict(
emb(llm_param(map(
 "instruction","测试",
 "embedding","true"
)))
) as content, "markdown" as mime 
as output;
```

## 启动和使用 bge 向量模型 

如果你要启动 bge 模型，可以这样：

```sql
!byzerllm setup single;
!byzerllm setup "num_gpus=0.5";
!byzerllm setup "maxConcurrency=2";

set node="master";
include http.`project.Libs.node`;

-- 部署embedding服务
run command as LLM.`` where 
action="infer"
and pretrainedModelType="custom/bge"
and localModelDir="/home/byzerllm/models/bge-large-zh"
and udfName="emb"
and reconnect="false"
and modelTable="command";
```

你可以按 m3e 相同的方式进行测试和使用。

## bge 特殊的问答匹配模式（必看）

我们知道 `问题` 和 `回答` 转化为向量后，他们并不是`相似`的. 所以 bge 提供了一个特殊的模式,允许你添加一个 prompt prefix 来提升这种
类型的生成效果。

```markdown
为这个句子生成表示以用于检索相关文章：测试文档
```

你可以这么用：

```sql

select llm_response_predict(
emb(llm_param(map(
 "instruction",concat("为这个句子生成表示以用于检索相关文章：","测试"),
 "embedding","true"
)))
) as content, "markdown" as mime 
as output;
```



