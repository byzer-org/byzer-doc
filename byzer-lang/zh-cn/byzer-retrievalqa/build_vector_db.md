# 构建向量索引库

前面我们启动了大语言模型，向量模型，现在我们可以准备数据，构建向量索引了。

## 准备数据

首先拉取 Byzer 文档：

```sql
-- 拉取 byzer文档
!sh git clone "https://gitee.com/allwefantasy/byzer-doc.git" "/home/byzerllm/projects/temp/byzer-doc";
```

接着加载 Byzer 文档：

```sql
-- 加载Byzer文档数据

load text.`file:///home/byzerllm/projects/temp/byzer-doc/byzer-lang/zh-cn/**/*.md` where
wholetext="true"
as byzerDoc;


select file as source, value as page_content from byzerDoc as newData;
```

注意，我们这里使用了 `wholetext="true"` 参数，这个参数会让 Byzer 加载整个文件为一行，而不是将文件切割按行加载。
其次，构建索引的表必须包含  source, page_content 两个字段。

## 构建索引

```sql
!byzerllm setup single;
!byzerllm setup "rayAddress=192.168.2.168:10001";
!byzerllm setup "num_gpus=0";

run newData as TableRepartition.`` where partitionNum="1" as newData2;

-- 使用业务数据构建向量数据库
run command as LLMQABuilder.`` 
where inputTable="newData2" 
and batchSize="0"
and chunkSize="2000"
and chunkOverlap="200"
and embeddingFunc="emb"
and chatFunc="llama_30b_chat"
and url="http://192.168.2.168:9003/model/predict"
and outputTable="byzer_docs_vdb_model";

-- 保存到数据湖
save overwrite byzer_docs_vdb_model as delta.`ai_model.byzer_docs_vdb_model`;
```

这里，我们使用了 `LLMQABuilder` 函数，该函数会将输入的数据，使用 `embeddingFunc` 函数进行向量化，然后使用 `chatFunc` 函数进行问答，最后将结果保存到 `outputTable` 指定的表中。最后将结果持久化到数据湖里。

注意，你需要将 `url` 参数修改为你的大模型服务地址。

`LLMQABuilder` 的参数，我们有如下 markdown 格式的表格：

| 参数名        | 说明                                                         |
| ------------- | ------------------------------------------------------------ |
| inputTable    | 输入表                                                       |
| batchSize     | 每次向量化的批次大小，现在请务必设置为 "0"                                         |
| chunkSize     | 将 page_content 切割成chunk, 每个chunk的大小                                         |
| chunkOverlap  | 每个chunk 互相重叠的字数                                         |
| embeddingFunc | 模型准备阶段启动的向量模型对应的函数                          |
| chatFunc      | 模型准备阶段启动的大语言模型对应的函数                   |
| url           | 大模型服务地址                                               |
| outputTable   | 输出表                                                       |


