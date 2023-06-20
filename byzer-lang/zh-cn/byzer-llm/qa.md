# Byzer-LLM 构建基于大模型问答知识库

Byzer 给知识库的全称定义是：使用用户私有数据基于大模型的问答知识库。这里有三个定语：

1. 用户私有业务数据
2. 基于大模型
3. 问答模式

其核心能力，是大模型阅读业务数据，然后根据自己的理解回答用户的问题。让用户使用业务数据更加简单。

涉及到两个标准动作：

1. 从业务数据自动召回上下文
2. 大模型基于上下文回答用户问题

构建知识库分成两部分：

1. 构建向量存储：将业务数据切割成一个一个chunk,每个chunk 通过大模型转化为向量表示，并且存储起来
2. 查询： 将用户问题转化为向量，召回chunk, 然后将chunk和用户问题一起给到大模型，大模型进行回复


Byzer-LLM 可以使用SQL 完成上述标准流程。

## 启动大模型/embedding服务

```sql
!byzerllm setup single;
run command as LLM.`` where 
action="infer"
and pretrainedModelType="chatglm"
and localPathPrefix="/my8t/byzerllm/jobs"
and localModelDir="/home/winubuntu/projects/glm-model/chatglm-6b-model"
and modelWaitServerReadyTimeout="300"
and reconnect="false"
and udfName="chatglm_chat"
and modelTable="command";
```

启动一个大模型。我们在后续的构建向量或者查询过程中都会使用到这个模型。注意这里，可以通过修改配置：

```sql
!byzerllm setup "maxConcurrency=1";
```

来控制该模型能够提供的并发能力。当起作为 embedding 服务时，默认单并发难以满足实际需求。

## 构建向量存储

加载一个影视数据：

```sql
load csv.`/tmp/upload/电影_A.csv` 
where header="true" and inferSchema="true"
as movies;

select title,concat(subtitle," ",subtitle2," ",`desc`) as content,actor, style,`地区` from movies 
as movies2;

select title as source, concat("影片标题:",title," 演员列表:",actor," 描述:",content,"类型:", style) as page_content from movies2 
as newData;

select * from newData where length(page_content)!=0 and length(source) != 0 as newData2;

```

最后我们得到了 newData2 表。请确保该表只有两个字段，source 和  page_content 字段。

现在让我们把这些影视数据全部构建成向量：

```sql
!byzerllm setup single;

-- run newData2 as TableRepartition.`` where partitionNum="2" as newData3;
select * from newData2 as newData3;
-- 使用业务数据构建向量数据库
run command as LLMQABuilder.`` 
where inputTable="newData3" 
and localPathPrefix="/my8t/byzerllm/jobs"
and batchSize="0"
and embeddingFunc="chatglm_chat"
and chatFunc="chatglm_chat"
and outputTable="movies_vec_store_glm";

-- 保存到数据湖
save overwrite movies_vec_store_glm as delta.`ai_model.movies_vec_store_glm`;
```

下面是 LLMQABuilder 的详细参数说明。

| Parameter | Description |
|--|--|
|localPathPrefix| 指定程序运行时的临时文件目录，默认为 /tmp |
|embeddingFunc| 指定embedding 服务的函数名称 |
|chatFunc| 指定对话模型服务的函数名称 |
|chunkSize| 指定对 page_content 字段的切割长度,默认生成长度为 600 的chunk  |
|chunkOverlap| 不同chunk之间的重叠程度。默认为 0  |
|inputTable| 输入表 |
|outputTable| 输出的向量文件表 |

现在，我们已经构建完向量存储，并且将文件保存到了数据湖。

关于构建性能，你可以对数据指定分片数目，这个数目最好对应 embedding服务的并发数目。 比如，假设我们 embedding 服务的并发度
为2,那么你可以通过下面的语句把我们的数据切分成两份，然后将新表传递给 LLMQABuilder

```sql
run newData2 as TableRepartition.`` where partitionNum="2" as newData3;
```


## 部署知识库服务

```sql
!byzerllm setup single;
!byzerllm "num_gpus=0";

-- 加载向量数据
load delta.`ai_model.movies_vec_store2` as movies_vec_store_model;

--- 部署
run command as LLM.`` where 
action="infer"
and reconnect="false"
and pretrainedModelType="qa"
and localPathPrefix="/my8t/byzerllm/jobs-t"
and modelWaitServerReadyTimeout="300"
and embeddingFunc="chatglm_chat"
and chatFunc="chatglm_chat"
and udfName="movice_qa"
and modelTable="movies_vec_store_model";
```

下面是部署的详细参数：

| Parameter | Description |
|--|--|
|localPathPrefix| 指定程序运行时的临时文件目录，默认为 /tmp |
|embeddingFunc| 指定embedding 服务的函数名称 |
|chatFunc| 指定对话模型服务的函数名称 |
|pretrainedModelType| 指定模型名称。这里固定为: qa |
|udfName| 指定知识库的函数名字 |
|modelTable| 指定之前我们构建好的向量文件 |

## 使用知识库

在完成构建，部署知识库后，现在可以使用知识库了。


```sql
set template="假设你是一位影视剧推荐官，你需要在我给的影视剧列表中寻找我询问的内容。下面是我给出的影视剧列表：\n {context} \n 请根据我的描述查找合适的影片。我的描述是：{query}。请只输出影片标题。" where scope="session";

select movice_qa(array(to_json(map(

"instruction",'我想看李连杰的电影',
"k","5",
"temperature","0.1",
"prompt","${template}"

)))) as response as output;
```

在上面这段代码中，我们设置了一个模板。其中里面有两个变量：

1. context ,这里会填充系统通过向量检索得到的影视数据，就是前面提到的chunk。
2. query, 这里自动回填充用户的问题，就是 instruction 字段指定的值。

最终渲染得到的一个完整文本会发送给大模型 chatglm_chat。

我们通过前面注册函数 movice_qa 和知识库进行交互。可选参数：

1. instruction 用户的问题
2. k 召回上下文的条数。不同模型的token限制不同，所以需要用户自己调整。
3. temperature, 回答的稳定性。推荐设置为 0 保证每次结果一致。
4. prompt 模板。你也可以把 template 字段里的值直接填充到 prompt 里去。


如果你想看召回的结果是什么样子的，也就是前面提到的 context, 你可以使用如下SQL 进行获取：


```sql
set template="假设你是一位影视剧推荐官，你需要在我给的影视剧列表中寻找我询问的内容。下面是我给出的影视剧列表：\n {context} \n 请根据我的描述查找合适的影片。我的描述是：{query}。请只输出影片标题。" where scope="session";

select movice_qa(array(to_json(map(

"instruction",'我想看李连杰的电影',   
"k","5",
"prompt","${template}",
"hint","show_only_context"

)))) as r as result;

select from_json(r[0],'array<struct<labels:string,predict:string>>')[0] as nr  from result as finalResult;

select explode(from_json(nr.predict,'array<struct<score:double,content:string>>')) as nr from finalResult as jsonTable;

select nr.score, nr.content from jsonTable order by score asc as output;

```

这里，我们多了一个 hint 字段，该字段目前支持两个值：

1. show_only_context  只获取向量查询结果
2. show_full_query 不仅展示回答，还要显示问题，同时还要展示向量查询耗时，问答耗时等信息

这两个hint 都是为了方便调试使用。