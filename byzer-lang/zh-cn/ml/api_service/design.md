# 设计和原理

使用 Byzer 完成模型训练后，部署模型并提供 API 服务是更为重要的一个环节。

通常，模型使用的场景有三个：

1. 批处理    比如对历史数据做统一做一次预测处理。
2. 流式计算  希望把模型部署在流式程序里。
3. API服务  希望通过API 对外提供模型预测服务（最常见）。

在 Byzer 中，所有的特征工程 `ET`（[什么是ET?](/byzer-lang/zh-cn/grammar/et_statement.md)）都可以被注册成UDF函数。

这样只要 API Server 支持注册这些函数，我们就可以通过这些函数的组合完成一个端到端的预测服务了。


### 原理图

所有训练阶段产生的 model 都可以被 API Server 注册，然后使用，无需开发便可实现端到端的预测。

```
训练阶段： 文本集合   ------  TF/IDF 向量(TFIDFInplace) ----- 随机森林(RandomForest) 

                               |                           |
产出                           model                       model
                               |                           |
                              register                    register
                               |                           |  
预测服务  单文本    -------     udf1     ---------------     udf2   ---> 预测结果
```





            