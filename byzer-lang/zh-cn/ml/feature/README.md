# 特征工程

做机器学习一大痛点就是训练阶段的特征工程代码无法复用在 API 预测阶段。

Byzer 提供了非常多的特征工程 `ET`（[什么是ET？]((/byzer-lang/zh-cn/grammar/et_statement.md))）,能够很好的解决这一痛点。

Byzer 内置这些 `ET` 有如下特点：

1. 训练阶段可用，保证吞吐量
2. 预测阶段使用，保证性能，一般毫秒级

本章节将具体讲解这些 ET 的使用。

### 系统需求

启动 Byzer 时，请使用--jars带上 [ansj_seg-5.1.6.jar](https://github.com/allwefantasy/streamingpro/releases/download/v1.1.0/ansj_seg-5.1.6.jar),[nlp-lang-1.7.8.jar](https://github.com/allwefantasy/streamingpro/releases/download/v1.1.0/nlp-lang-1.7.8.jar).
因为在很多示例中，我们需要用到分词相关的功能。







