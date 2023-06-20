# SQL 多轮聊天

我们也可以直接使用 SQL 进行多轮聊天。

比如在 Notebook 的多轮多话用纯SQL实现，如下：

第一段对话：

```sql
select chat(llm_param(map(
    "system_msg",'You are a helpful assistant. Think it over and answer the user question correctly.',
    "instruction",'你好，请记住我的名字，我叫祝威廉。如果记住了，请说记住。',
    "temperature","0.1",
    "user_role","User",
    "assistant_role","Assistant"
))) as q as q1;
```

这里，我们使用 `llm_param` 函数组装chat 函数需要的请求数据格式,并且我们给
对话通过表名来标记， 起名为 q1。

接着我们进行第二段对话：

```sql
select  chat(llm_stack(q,llm_param(map(
    
    "instruction",'请问我叫什么名字？',
    "temperature","0.1",
    "user_role","User",
    "assistant_role","Assistant"
)))) as q from q1 as q2;

```

这里我们基于 q1 进行进行对话，这里是通过 `llm_stack`  函数来配合的。 `llm_stack` 函数接受两个参数：

1. 上一轮对话的结果 q
2. 这次对话的参数，也就是通过 llm_param 函数来进行拼接。

llm_stack 会自动从从 q1 表的 q 字段抽取历史对话信息，并且和当前的新构建的对话信心进行组合，然后转化成模型可以接受的格式，
从而实现多轮对话。

此外，我们可能经常需要模板的功能，Byzer-LLM 提供了 llm_prompt 函数，该函数可以使用SQL 表中的字段进行prompt 进行渲染。

比如下面的例子：

```sql
select id,
chat(llm_param(map(
              "system_msg",'You are a helpful assistant. Think it over and answer the user question correctly.',
              "instruction",llm_prompt('
Use the following Contents and Rules answer the question at the end. If you do not know the answer, just say that you do not know, do not try to make up an answer.

The Contents:

```
{0}
```

Please summary the Contents.
',array(Contents))

)))

 as q,Rules from it_table as q1;
 
```

我们使用 `{0}` 作为占位符，然后使用 `it_table` 表中的 `Contents` 对该占位符进行替换，之后把渲染的新内容再通过 `llm_param` 函数进行组装，
最后交给 chat 函数进行应答。 注意这里，你可以使用多个占位符，从而传递多个参数，只要按序号传递即可。


比如下面的例子，

```sql
select llm_prompt('
Use the following Contents and Rules answer the question at the end. If you do not know the answer, just say that you do not know, do not try to make up an answer.

The Contents:

```
{0}
```

{1}

{0}

Please summary the Contents.
',array(Contents,"YES")))

as template as output;
```

`{0}` 会被 Contents 字段替换， `{1}` 会被 "YES" 字符串替换。用户可以在Notebook 自行体验。

