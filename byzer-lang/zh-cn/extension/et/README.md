# Estimator/Transformer

byzer 内置了非常多的Estimator/Transformer 帮助用户去解决一些用SQL难以解决的问题。我们先来看看Estimator/Transformer
是什么。

通常而言，Estimator会学习数据，并且产生一个模型。而Transformer则是纯粹的数据处理。通常我们认为算法是一个 Estimator，而算法训练后产生
的模型则是 Transformer。大部分数据处理都是 Transformer，SQL中的select语句也是一种特殊的 Transformer。

在接下来的章节里，我们介绍一些有趣而实用的 Estimator/Transformer，帮助大家更好的解决工作中的问题。