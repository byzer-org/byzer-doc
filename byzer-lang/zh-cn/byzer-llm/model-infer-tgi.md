# Byzer-LLM 推理性能优化

> 该功能目前为测试功能，且仅支持部分模型

Byzer-LLM 默认使用原生 Transformer 进行推理，但 Transformer 默认的切分策略多多卡情况效率并不高。
所以 Byzer-LLM 集成了部分 TGI 的能力来优化推理性能。

然而，要想获得性能提升，TGI 需要用户额外在服务器上做一些配置。

进入 byzer-llm 项目

安装 TGI Kernel

```
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