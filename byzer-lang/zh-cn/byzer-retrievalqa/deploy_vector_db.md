# 部署向量数据库

我们的向量索引文件已经保存到数据湖，现在我们可以部署一个实例了。

```sql
-- 现在，我们可以把向量查询和大模型结合起来，
-- 提供一个新的函数 qa
!byzerllm setup single;
!byzerllm setup "num_gpus=0";

-- 加载向量数据
load delta.`ai_model.byzer_docs_vdb_model` as byzer_docs_vdb_model;

--- 部署
run command as LLM.`` where 
action="infer"
-- 配置查询节点向量数据的本地存储路径，方便后续清理
and localPathPrefix="/home/byzerllm/projects/byzer_docs_vdb_model"
and pretrainedModelType="qa"
and udfName="byzer_docs_qa"
and embeddingFunc="emb"
and chatFunc="llama_30b_chat"
and url="http://192.168.2.168:9003/model/predict"
and modelTable="byzer_docs_vdb_model";
```

启动后，你应该可以在 Ray Dashboard 的 Actors 页面看到一个名字为 `byzer_docs_qa` UDFMaster。

注意，你需要将 `url` 参数修改为你的大模型服务地址。

`LLM` 的参数，我们有如下 markdown 格式的表格：

| 参数名        | 说明                                                         |
| ------------- | ------------------------------------------------------------ |
| action        | 固定为 "infer"                                                |
| localPathPrefix | 配置查询节点向量数据的本地存储路径，方便后续清理 |
| pretrainedModelType | 固定为 "qa" |
| udfName | UDF 名称 |
| embeddingFunc | 模型准备阶段启动的向量模型对应的函数 |
| chatFunc | 模型准备阶段启动的大语言模型对应的函数 |
| url | 大模型服务地址 |
| modelTable | 向量索引表 |


| 参数名        | 说明                                                         |
| ------------- | ------------------------------------------------------------ |
| strategy | 向量召回策略。目前有 full_doc 和 norml。 norml 为直接召回 chunk 文本片段。 full_doc 则会在召回的chunk中，找到被最多chunk指向的那篇万丈文档 |
| format | 拼接chunk的策略。目前有 list/json/normal。 normal 将不同chunk使用换行来拼接。 list 前面会加序号。json 则会将chunk按 json数组格拼接  |
| hint | 控制问答生成参数。目前有 show_only_context/show_full_query/normal。 其中 show_only_context 只会执行召回，show_full_query 会显示最后给到大模型的新query, normal 则为正常的服务模式。  |    
| max_length | 传递给大模型的参数，支持最大的文本长度,默认为 1024 |
| temperature | 传递给大模型的参数，热度，默认为 0.9 |

