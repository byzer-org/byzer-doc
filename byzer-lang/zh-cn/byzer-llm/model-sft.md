## Byzer-LLM 模型微调

> 2023-08-08

本文详细介绍在Byzer-LLM 使用 QLora 进行单机多卡微调。

## 已经测试过支持微调的模型(截止至2023-08-08)

1. sft/chatglm2
2. sft/baichuan
3. sft/falcon
4. sft/llama2

> 新增模型我们需要一一验证，需要点时间，敬请期待。

其中 

1. chatglm2 需要 pytorch 2.0.1 才能在消费级显卡上微调 （flash attension的限制）
2. chatglm2 需要修改模型权重文件目录里的 tokenization_chatglm.py 第 72 行代码。在其后添加一条新语句（bug，等待官方修复）：

```python
self.vocab_file = vocab_file
```


## 数据格式

Byzer-LLM 微调支持两种QA格式的数据。

第一种是 Alpaca 格式

```
instruction string
input string
output string
history array<array<string>>
```

第二种是 Moss 格式：

```
category  string
conversation array<struct<assistant:string,human:string>>
conversation_id bigint
dataset string
```

尽管如此，只要是对话数据，你也可以自己通过SQL拼接成上面的格式(Byzer拥有很强大的数据处理能力)，再进行微调。

## 微调步骤

加载数据：

```sql
load json.`file:///home/winubuntu/projects/Firefly/data/dummy_data.jsonl` where
inferSchema="true"
as sft_data;

```

微调模型：


```sql

-- 测试Llama2模型微调
!byzerllm setup sft;
!byzerllm setup "num_gpus=4";

run command as LLM.`` where 
and localPathPrefix="/home/byzerllm/models/sft/jobs"

-- 指定模型类型
and pretrainedModelType="sft/llama2"

-- 指定模型
and localModelDir="/home/byzerllm/models/Llama-2-7b-chat-hf"
and model="command"

-- 指定微调数据表
and inputTable="sft_data"

-- 输出新模型表
and outputTable="llama2_300"

-- 微调参数
and  detached="true"
and `sft.int.max_seq_length`="512";
```

前面我们假设服务器上有模型了。

## 使用数据湖管理模型

如果你想使用数据湖拉取模型并保存，需要额外消耗18-30分钟（26g左右大小的模型文件夹）。正常情况考虑到微调本身就需要较长的实际运行时间，这点额外开销微不足道。

如果是这样，需要改成如下方式进行微调：


```sql
load model.`/home/byzerllm/models/Llama-2-7b-chat-hf` as llama2_7b;

!byzerllm setup sft;

run command as LLM.`` where 
and localPathPrefix="/home/byzerllm/models/sft/jobs"
and pretrainedModelType="s/baichuan"
and model="llama2_7b"
and inputTable="sft_data"
and outputTable="llama2_300"
and `sft.int.max_seq_length`="512";

-- 保存模型
save overwrite llama2_300 as delta.`ai_model.llama2_300`;
```

相比之前的代码：

1. 原始模型使用 load 语法加载
2. 使用 model 参数配置模型表。去掉 `localModelDir`
3. 最后通过save 保存模型

## 如何查看模型训练进度

在Notebook提交后，可以在 8265 端口查看 Actor，地址通常是：http://127.0.0.1:8265/#/actors， 找到名字默认为 `sft-william-xxxxx` 的Actor， 
在该 Actor 的日志控制台你可以看到类似如下信息：

```
Loading data: /home/byzerllm/projects/sft/jobs/sft-william-20230809-13-04-48-674fd1b9-2fc1-45b9-9d75-7abf07cb84cb/finetune_data/data.jsonl3
2
there are 33 data in dataset
*** starting training ***
{'train_runtime': 19.0203, 'train_samples_per_second': 1.735, 'train_steps_per_second': 0.105, 'train_loss': 3.0778136253356934, 'epoch': 0.97}35

***** train metrics *****36  
epoch                    =       0.9737  
train_loss               =     3.077838  
train_runtime            = 0:00:19.0239  
train_samples_per_second =      1.73540  
train_steps_per_second   =      0.10541

[sft-william] Copy /home/byzerllm/models/Llama-2-7b-chat-hf to /home/byzerllm/projects/sft/jobs/sft-william-20230809-13-04-48-674fd1b9-2fc1-45b9-9d75-7abf07cb84cb/finetune_model/final/pretrained_model4243              
[sft-william] Train Actor is already finished. You can check the model in: /home/byzerllm/projects/sft/jobs/sft-william-20230809-13-04-48-674fd1b9-2fc1-45b9-9d75-7abf07cb84cb/finetune_model/final   
```

表示模型训练成功，可以找到对应节点进行模型下载或者通过脚本自动同步到所有机器上。

注意，你也可以前面的训练脚本中，通过 name 参数显示的给这个Actor取一个名字，方便你定位找到该Actor。


## 部署微调模型

```sql
-- 部署微调后的模型

!byzerllm setup single;
-- 如果没有做模型分发，那么可以确认下模型在哪台机器上，在这个集群分别是 master,worker_1,worker_2 三台机器，然后模型
-- 在 master 节点上，我们就让部署进程自动调度到 master 节点上。
!byzerllm setup "resource.master=0.01";

run command as LLM.`` where 
action="infer"
and localPathPrefix="/home/byzerllm/models/infer/jobs"
and localModelDir="/home/byzerllm/models/sft/jobs/sft-william-20230809-13-29-10-757c54e4-0d62-423a-a4ef-f9fbeb3d9bf1/finetune_model/final"
and pretrainedModelType="custom/llama2"
and udfName="llama2_chat"
and modelTable="command";

```

## 验证

在 Notebook 中验证部署后的模型

```sql
--%chat
--%model=llama2_chat
--%system_msg=You are a helpful assistant. Think it over and answer the user question correctly.
--%user_role=User
--%assistant_role=Assistant
--%output=q1

推荐一部电影
```

## 参数说明


其中 `sft.int.max_seq_length` 用来指定微调参数。该参数由三部分构成：

1. sft 参数前缀
2. int  参数类型
3. max_seq_length 参数名称

下面是是一些默认参数列表，同时为您提供了可配置的参数列表：

```json
DEFAULT_QLORA_CONFIG = {    
    'num_train_epochs': 1,
    'per_device_train_batch_size': 1,
    'gradient_accumulation_steps': 16,
    'learning_rate': 0.0002,
    'max_seq_length': 1024,
    'logging_steps': 300,
    'save_steps': 500,
    'save_total_limit': 1,
    'lr_scheduler_type': 'cosine',
    'warmup_steps': 3000,
    'lora_rank': 64,
    'lora_alpha': 16,
    'lora_dropout': 0.05,
    'gradient_checkpointing': False,
    'disable_tqdm': False,
    'optim': 'paged_adamw_32bit',
    'seed': 42,
    'fp16': True,
    'report_to': 'tensorboard',
    'dataloader_num_workers': 0,
    'save_strategy': 'steps',
    'weight_decay': 0,
    'max_grad_norm': 0.3,
    'remove_unused_columns': False
 }
```

在上面的例子中，我们修改了 `max_seq_length` 为 512,这样可以让 7B 的百川模型在消费级的 24G 显卡中即可运行微调任务。

