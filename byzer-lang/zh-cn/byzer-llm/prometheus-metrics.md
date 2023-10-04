# Prometheus 对接

## 扩展

1.  Byzer-LLM Java extension >= 0.1.4  
2.  Byzer-LLM Python extension >= 0.1.4 

下载 https://download.byzer.org/byzer-extensions/nightly-build/byzer-llm-3.3_2.12-0.1.4.jar 放到 Byzer 引擎
plugin 目录下。

使用 pip 安装 byzerllm==0.1.4

## 说明

Byzer-LLM 需要搭配 pushgateway 使用，基本流程是 Byzer-LLM 将数据推送到 pushgateway 中，再由 Prometheus 采集。

## 配置

在 Byzer 引擎的 `conf/byzer.properties.override` 添加如下配置：

```
spark.mlsql.ray.config.service.enabled=true
spark.mlsql.pushgateway.address=127.0.0.1:9098
```

第一个参数开启 Byzer 配置服务， 第二个参数配置 pushgateway 地址。配置好着两个参数后，Byzer-LLM 就会将数据推送到 pushgateway 中。

## 指标

vllm backend 的推理，我们会统计每个推理实例的 token 数，

1. infer_{INFERENCE_NAME}_input_tokens_num
2. infer_{INFERENCE_NAME}_output_tokens_num

其中 INFERENCE_NAME 为推理(部署时的udf_name)名称，比如 `falcon_40b_chat`。

微调时，我们会统计每个微调实例的 token 数，

1. sft_{sft_name}_tokens_num

其中 sft_name 为微调(启动微调时的name)名称，比如 `sft_falcon_40b_william` 之类的。

## Byzer 配置服务

前面第一个参数：

```
spark.mlsql.ray.config.service.enabled=true
```

该参数开启后，Byzer 引擎启动后，会在 Ray 启动一个叫做 `__MLSQL_CONFIG__` 的服务，并且推送配置到该服务中。从而可以让 Ray 获得 Byzer 引擎 `conf/byzer.properties.override` 中的配置信息。

这里存在几个问题：

1. Byzer 重启后，会杀死原有的`__MLSQL_CONFIG__` 服务，启动一个新的，并且重新推送配置，导致 Ray 中的老配置被覆盖。
2. 如果多个 Byzer 引擎连接同一个 Ray 集群，最后一个启动的 Byzer 引擎的配置会生效。最好的解决办法是只在其中一个主 Byzer 引擎中开启该配置。
