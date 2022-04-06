# 特征工程

什么是特征工程？

有这么一句话在业界广泛流传：数据和特征决定了机器学习的上限，而模型和算法只是逼近这个上限而已。那特征工程到底是什么呢？顾名思义，其本质是一项工程活动，目的是最大限度地从原始数据中提取特征以供算法和模型使用。

Byzer 提供了非常多的特征工程算子,能够很好的解决这一痛点。

Byzer 内置的这些特征工程算子有如下特点：

1. 训练阶段可用，保证吞吐量
2. 预测阶段使用，保证性能，一般毫秒级

本章节将具体讲解这些 ET 的使用。

### 系统需求

启动 Byzer 时，请使用--jars带上 [ansj_seg-5.1.6.jar](https://github.com/allwefantasy/streamingpro/releases/download/v1.1.0/ansj_seg-5.1.6.jar),[nlp-lang-1.7.8.jar](https://github.com/allwefantasy/streamingpro/releases/download/v1.1.0/nlp-lang-1.7.8.jar).
因为在很多示例中，我们需要用到分词相关的功能。







