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



