# Byzer-LLM 推理性能优化

> 该功能目前为测试功能，且仅支持部分模型

Byzer-LLM 默认使用原生 Transformer 进行推理，但 Transformer 默认的切分策略多多卡情况效率并不高。
所以 Byzer-LLM 集成了部分 TGI 的能力来优化推理性能。

然而，要想获得性能提升，TGI 需要用户额外在服务器上做一些配置。

> 如果你是使用 setup-machine.sh 脚本部署的环境, 则无需依赖库的安装部分

## 依赖库

进入 byzer-llm 项目

安装 TGI Kernel

```shell
git clone https://gitee.com/mirrors/text-generation-inference
cd text-generation-inference/server/custom_kernels
pip install .
```

重新回到 byzer-llm 根目录。

安装 TGI flash-attention 依赖：

```shell

```shell
make install-flash-attention
```

安装 TGI vllm 依赖：

```shell
make install-vllm
```

## 将模型转换为 safetensors 格式

可通过如下指令执行

```shell
git clone https://gitee.com/allwefantasy/byzer-llm
cd byzer-llm/setup-machine
python convert_safetensor.py 模型路径
```

## 加载模型

```sql
!byzerllm setup single;
!byzerllm setup "num_gpus=4";
!byzerllm setup "maxCocurrency=1";

run command as LLM.`` where 
action="infer"
and pretrainedModelType="falcon"
-- this line change the inference mode to tgi
and inferMode="tgi"
and localModelDir="/home/byzerllm/models/falcon-40b/"
and reconnect="false"
and udfName="falcon_40b_chat"
and modelTable="command";

```

