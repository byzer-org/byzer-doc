# 查询知识库

我们可以直接像使用大模型那样使用知识库。

首先我们设置一个模板：

```sql
-- 设置模板
set template='''User: You are a helpful assistant. Think it over and answer the user question correctly. 
{context}
Please answer based on the content above? ：
{query}
Assistant:''' where scope="session";


```

然后我们可以使用 `byzer_docs_qa` 函数进行问答了：

```sql
--查看完整结果
select llm_response_predict(
byzer_docs_qa(llm_param(map(
"instruction","请使用 Byzer 加载一个csv文件",
"k",1,
"prompt","${template}",
"strategy","full_doc",
"format","json",
"temperature",0.1
)))
) as response as output;
```

查询常见参数：

| 参数名        | 说明                                                         |
| ------------- | ------------------------------------------------------------ |
| strategy | 向量召回策略。目前有 full_doc 和 norml。 norml 为直接召回 chunk 文本片段。 full_doc 则会在召回的chunk中，找到被最多chunk指向的那篇万丈文档 |
| format | 拼接chunk的策略。目前有 list/json/normal。 normal 将不同chunk使用换行来拼接。 list 前面会加序号。json 则会将chunk按 json数组格拼接  |
| hint | 控制问答生成参数。目前有 show_only_context/show_full_query/normal。 其中 show_only_context 只会执行召回，show_full_query 会显示最后给到大模型的新query, normal 则为正常的服务模式。  |    
| max_length | 传递给大模型的参数，支持最大的文本长度,默认为 1024 |
| temperature | 传递给大模型的参数，热度，默认为 0.9 |
