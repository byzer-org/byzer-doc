# 如何使用 Byzer Notebook 作为聊天框

第一步，部署一个模型，开源私有或者Saas API 都可以。

具体部署代码如下：

```

!byzerllm setup single;

run command as LLM.`` where 
action="infer"
and pretrainedModelType="llama"
and localModelDir="/home/winubuntu/projects/llama-7b-cn"
and udfName="chat"
and modelTable="command";
```

这里我们部署了一个 llama7b 模型，并且将该函数映射成 `chat` 函数。 这个名字可以随意。

接着通过注释和该模型对话：

```sql
--%chat
--%model=chat
--%system_msg=You are a helpful assistant. Think it over and answer the user question correctly.
--%user_role=User
--%assistant_role=Assistant
--%output=q0

你好,请记住我的名字，祝威廉。
```

上面注释其实就是一些配置，这些配置的含义如下：


| name | description |
|:--|:--|
|chat| 这个参数是个标记参数，表示这个 Notebook Cell 是一个聊天输入框|
|model| 我们前面部署的函数名称，这里是chat|
|system_msg|第一次聊天，可以设置的一个系统消息。You are a helpful assistant. Think it over and answer the user question correctly.|
|user_role|比如上面设置成User，那么在产生的消息对话中，用户消息使用 User: 进行标记|
|assistant_role|比如上面设置成Assistant，那么在产生的消息对话中，模型的输出消息使用 Assistant: 进行标记|
|output|该会话的引用|
|input|基于那个对话继续往后聊|


```sql
--%chat
--%model=chat
--%user_role=User
--%assistant_role=Assistant
--%input=q0
--%output=q1

请问我的名字是什么
```

这个是我们第二段对话，其中我们把 input设置为 q0, 这个时候会接着 q0 聊，所以系统能够顺利的说出我的名字。
此时也不需要在设置 system_msg, 因为我们在对话 q0 已经设置过了。

后续对话只要不断变化  input/output，形成对话链路就可以。 

我们也可以跳过一些对话，比如现在有 q0, q1... q9 十段对话，如果希望跳过 q1-q6 这六个对话，那么可以将q7 的input设置为 q0, 此时
对话内容为 q0 q7 q8 q9。








