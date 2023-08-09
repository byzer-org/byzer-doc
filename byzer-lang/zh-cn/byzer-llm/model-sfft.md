# Byzer-LLM 做模型预训练

> 2023-08-08

Byzer-LLM 支持两种预训练模式，分别是：

1. 从头开始预训练
2. 从已有模型继续预训练

目前支持下面两个模型：

1. sfft/llama2
2. sfft/baichuan

> 新增模型我们需要一一验证，需要点时间，敬请期待。


## 从已有模型继续预训练

加载文本类数据。也可以用微调格式数据，加载后用 Byzer SQL 语法进行拼接，最终只要保证数据表有
`text` 字段即可。 该字段为一段普通文本，字段长度最好喝我们要训练的配置的 `max_length` 保持一致。


```sql
-- 加载收集到的文本数据
load text.`file:///home/byzerllm/data/raw_data/*`
where wholetext="true" as trainData;

select value as text,file from trainData  as newTrainData;
```

接着假设我们要使用24块卡（大概三台8卡3090服务器）进行训练。
下面是训练代码：

```sql

-- 把数据切割成24份，因为我们后续要用24块卡来训练
-- 这里需要保证 Byzer引擎的所在服务器至少有24+CPU 可用，否则可能会导致
-- 任务hang住
run newTrainData as TableRepartition.`` where partitionNum="24" and partitionCols="file" as finalTrainData;


--设置环境，比如总共使用 24 块卡做预训练
!byzerllm setup sfft;
!byzerllm setup "num_gpus=24";


-- 指定原始的模型进行二次预训练
run command as LLM.`` where 
-- 给训练起个名字
name="sfft-wiliam-llama2-pretrain"
and localPathPrefix="/home/byzerllm/models/sfft/jobs"
and pretrainedModelType="sfft/llama2"
-- 原始模型
and localModelDir="/home/byzerllm/models/Llama-2-7b-chat-hf"
-- and localDataDir="/home/byzerllm/data/raw_data"

-- 异步执行，因为这种训练往往需要几天几周甚至几个月。用户可以在
-- Ray Dashboard 找到 tensorboard 的地址，然后观察Loss
and detached="true"
and keepPartitionNum="true"

-- 配置deepspeed, 可选
-- and deepspeedConfig='''${ds_config}'''

-- 用来做预训练的数据
and inputTable="finalTrainData"
and outputTable="llama2_cn"
and model="command"

-- 一些特殊的预训练参数
and `sfft.int.max_length`="128"
-- 一些异构服务器网络设备号命名不统一，会导致ncll通信失败，这里设置为true就好
and `sfft.bool.setup_nccl_socket_ifname_by_ip`="true"
;
```

上面的代码会自动 Setup tensorboard, 在 Ray dashboard里找到名字为 `sfft-wiliam-llama2-pretrain`(你上面代码中起的名字)的Actor，如果没有起名字，默认会是 `sft-用户名-日期`。 进入该 Actor 查看日志， Tensorboard地址，访问改地址，就可以观察 Loss 情况。


训练完成后， 在Ray Dashboard 可以根据名字找到 Rank 为 0 的节点（名字默认格式为：W-0-sfft-wiliam-llama2-pretrain 或者 W-0-sfft-用户名-日期），里面会打印checkpoint 路径，登录对应服务器，找到checkpoint。然后拷贝出来，即可得到模型。

上面还有个参数需要特别介绍下，叫 `deepspeedConfig`, 这里可以配置一个标准的 deepspeed 配置。比如下面这个配置：

```sql
set ds_config='''
{
  "gradient_accumulation_steps": 1,
  "train_micro_batch_size_per_gpu": 1,
  "prescale_gradients": false,
  "zero_allow_untested_optimizer": true,
  "optimizer": {
    "type": "AdamW",
    "params": {
      "lr": 1e-8,
      "eps": 1.0e-8,
      "betas": [
        0.9,
        0.95
      ],
      "weight_decay": 0.1
    }
  },
  "tensorboard": {
    "enabled": true
  },
  "zero_optimization": {
    "stage": 3,
    "offload_optimizer": {
         "device": "cpu"         
     },           
    "offload_param": {
         "device": "cpu"
    },
    "contiguous_gradients": true,
    "allgather_bucket_size": 1e8,
    "reduce_bucket_size": 1e8,
    "overlap_comm": true,
    "reduce_scatter": true
  },
  "steps_per_print": 16,
  "gradient_clipping": 1.0,
  "wall_clock_breakdown": true,
  "bf16": {
    "enabled": true
  }
}
''';
```

你可以根据需要修改上述配置，这样会覆盖掉默认一些配置。


## 从头开始预训练

从头开始训练则无需有初始模型，现阶段我们只提供了 Python API, 具体代码如下：

```python
from byzerllm.utils.fulltune.pretrain import BaiChuanForCausalLM,ParallelConfig,TrainArgs
from byzerllm.utils.fulltune.base_model.configuration_baichuan import BaiChuanConfig
from byzerllm.utils.fulltune.base_model.modeling_baichuan import BaiChuanForCausalLM
import ray
import json
from transformers import AutoTokenizer, AutoModelForCausalLM,BitsAndBytesConfig

# ray.util.connect(conn_str="127.0.0.1:10001")
ray.init(address="auto",ignore_reinit_error=True)

MODEL_DIR = "/home/byzerllm/models/Llama-2-7b-chat-hf"

def get_model():
    return BaiChuanForCausalLM(BaiChuanConfig())    

dst = DeepSpeedTrain(ParallelConfig(
  num_workers=16,
  get_model = get_model,
  ds_config=json.loads(DEFUALT_CONFIG),  
  setup_nccl_socket_ifname_by_ip=True,
  train_args=TrainArgs(
      model_path=MODEL_DIR,
      tokenizer_path = f"{MODEL_DIR}/tokenizer.model",
      data_dir = "/home/byzerllm/data/raw_data",  
      checkpoint_saving_path = "/home/byzerllm/data/checkpoints",   
      steps_per_epoch = 10,
      max_length = 128
  )
))

ray.get([worker.train.remote() for worker in dst.workers])
```
