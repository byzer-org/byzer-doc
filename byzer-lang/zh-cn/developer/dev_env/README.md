## Byzer Engine开发环境设置
<center><img src="/byzer-lang/zh-cn/developer/dev_env/images/dev_env_index_management.png" /></center>
<center><img src="/byzer-lang/zh-cn/developer/dev_env/images/dev_env_analysis.png" /></center>

Byzer 主要使用 Java/Scala 开发，所以我们推荐使用 Idea IntelliJ 社区版进行开发。

Byzer Engine 内部的执行引擎是 Spark，尽管在设计的时候可以使用其他引擎替换（如 Flink），但目前 Spark 为其唯一实现。

通常而言，Byzer 会支持 Spark 最近的两个大版本,截止到本文写作时间，我们支持 2.4.x，3.0.x。 经过测试的为准确版本号为 2.4.3 / 3.0.0 / 3.0.1。

因为要同时支持两个版本，但是 Spark 不同版本的 API 往往发生变化，我们使用 Maven 的 profile 机制切换不同的模块支持。

<center><img src="/byzer-lang/zh-cn/developer/dev_env/images/dev_env_streamingpro.png" /></center>

红色框选部分，展示了我们对 spark 2.3，2.4，3.0 进行了适配。实际上 2.3 已经不再维护了。在未来 3.1 版本适配完成后，会删除 2.3 这个适配。

用户可以通过 git 下载[源码](https://github.com/allwefantasy/mlsql.git)。

这是一个 Maven 项目，用户只要是有用 idea 按 Maven 项目打开即可。在后续章节里，我们会详解介绍如何基于 Spark 2.4.3 和 3.0.0 开发 Byzer 。

