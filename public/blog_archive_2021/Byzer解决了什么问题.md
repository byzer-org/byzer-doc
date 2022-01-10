# Byzer 解决了什么问题（一）

### 数据中台的概念
在谈 Byzer 解决了什么问题之前，我们先提一个“数据中台”的概念。什么是数据中台呢？数据中台至少应该具备如下三个特点：

在不移动数据的情况下，提供全司视角数据视图，并且能够将这种能力释放给兄弟部门。
在不干涉其他部门 API 定义的情况下，提供全司视角的（也包括外部 API）的 API 服务视图，并且能够在中台中组装使用。
所有的人都可以在数据中台上以统一的，简单的语言，结合第二点中提到的 API 服务能力，在中台中对第一点中提到的数据进行加工处理，这些加工处理包括批处理，流式，包括机器学习训练，批预测，提供 API 服务等。
简而言之，数据中台应该是分析师，算法，研发，产品，运营甚至老板日常工作的集中式的控制台。Byzer 就可以做成这么一件事，为什么呢？因为 Byzer 是一门语言，同时也是一个引擎，通过周边配套，就可以做成这么一件事情。

这个概念有点大，大家不一定能理解。我们再来聊聊大家的痛点，切肤之痛更易于感同身受。

### 大数据研发同学看这里的痛点
1. 很多情况大数据平台和算法平台是割裂的，这就意味着人员和工作流程，还有研发方式，语言都是割裂。
2. 在大数据平台里面，批处理，流式，API服务等等都是割裂的。我们依赖的是低级别的语言，比如 Scala/Java/Go/Python 等等，每个人写出的代码各有千秋，分析师，研发，数仓各自看不懂对方的东西。
3. 起点低，都快进入了 2019 年了，很多同学们还在用一些比较原始的技术和理念，比如还在大量使用类似 yarn 调度的方式去做批任务，流式也还停留在 JStorm，Spark Streaming 等技术上。哪怕是没有多少历史包袱的公司也是。
我们会有大量的项目需要维护，而在我看来，一个中小型大数据部门，2-3 个核心项目仓库是最理想的。代码维护是昂贵的。
4. Byzer 首先是弥合了大数据平台和算法平台的割裂，这是因为 Byzer 对算法有着非常友好的支持。我们看一个比较典型的示例：

```sql
-- load data
load parquet.`${rawDataPath}` as orginal_text_corpus;
 
-- select only columns we care
select feature,label from orginal_text_corpus as orginal_text_corpus;
 
-- feature enginere moduel
train zhuml_orginal_text_corpus  as TfIdfInPlace.`${tfidfFeaturePath}` 
where inputCol="content" 
and `dic.paths`="/data/dict_word.txt" 
and stopWordPath="/data/stop_words"
and nGrams="2";
 
-- load data
load parquet.`${tfidfFeaturePath}/data` as tfidfdata;
 
--  algorithm module
train zhuml_corpus_featurize_training as PythonAlg.`${modelPath}` 
where pythonScriptPath="${projectPath}"
-- distribute data
and  enableDataLocal="true"
and  dataLocalFormat="json"
-- sklearn params
and `fitParam.0.moduleName`="sklearn.svm"
and `fitParam.0.className`="SVC"
and `fitParam.0.featureCol`="features"
and `fitParam.0.labelCol`="label"
and `fitParam.0.class_weight`="balanced"
and `fitParam.0.verbose`="true"
 
and `fitParam.1.moduleName`="sklearn.naive_bayes"
and `fitParam.1.className`="GaussianNB"
and `fitParam.1.featureCol`="features"
and `fitParam.1.labelCol`="label"
and `fitParam.1.class_weight`="balanced"
and `fitParam.1.labelSize`="2"
 
-- convert model to udf
register  TfIdfInPlace.`${tfidfFeaturePath}` as tfidf_transform;
register  PythonAlg.`${modelPath}` as classify_predict;
 
-- predict
select classify_predict(tfidf_transform(feature)) from orginal_text_corpus as output;
```
这段脚本完成了数据加载，处理 tfidf 化，并且使用两个算法进行训练，注册模型为函数，最后调用函数进行预测，一气呵成。大家可以看这个 PPT，了解 Byzer 如何进行批，流，算法，爬虫相关的工作。这个文档同时也说明了 Byzer 如何解决上面提到的第二个痛点。

第三个问题，Byzer 底层集合了譬如 Spark，Tensorflow/Sklearn 等各种主流技术以及大数据相关的思想，所以其实并不需要你关注太多。

### 算法的同学看这里的痛点
我们假设大部分算法的代码都是基于 Python 的：

1. 项目难以重现，可阅读性和环境要求导致能把另外一个同事写的 python 项目运行起来不得不靠运气
2. 和大数据平台衔接并不容易，需要让研发重新做工程实现，导致落地周期变长。
3. 训练时数据预处理/特征化无法在预测时复用
4. 集成到流式，批处理和提供API服务都不是一件容易的事情
5. 代码/算法复用级别有限，依赖于算法自身的经验以及自身的工具箱，团队难以共享。
6. 其他团队很难接入算法的工作

基本算法工程师搞了个算法，很可能需要两周才能上线，你说怎么才能迭代变快。两周上线不可怕，可怕的是每个项目都是如此。

那么  Byzer 怎么去解决呢？我们知道，如果是简单的 SQL 怎么可能满足算法和工程的要求呢，所以我们提供了 Byzer, Byzer 具备高度扩展能力，这包括：

Estimator/Transformer，前面我们看到 train 语法里的 TfIdfInPlace，PythonAlg 这些模块你可以用现成的，研发也可以扩展，然后 `--jars` 带入后就可以使用。
Byzer 提供了在脚本中写 python/scala UDF/UDAF 的功能，这就意味着你可以通过代码无需编译和部署就能扩展 Byzer 的功能。
Byzer 的 PythonALg 模块可以集成任何 Python 算法项目。我们通过借鉴 MLFlow 的一些思想可以很好的解决 Python环境依赖问题，并且比 MLFlow 具有更少的侵入性。
另外，前面我们提到“训练时数据预处理/特征化无法在预测时复用“，尤其是还存在跨语言的情况，研发需要翻译算法的代码。Byzer 因为大家用的都是同一个语言，所以不存翻译的问题。

那么如何解决预处理/特征化复用呢？我们知道，在训练时，都是批量数据，而在预测时，都是一条一条的，本身模式就都是不一样的。所以传统的模式是很难复用的，在 Byzer 里，所谓数据处理无非就是 SQL+UDF Script+Estimator/Transformer, 前面两个复用其实没啥问题，Estimator/Transformer 在训练时，接受的是批量的数据，并且将学习到的东西保存起来，之后在预测时，会将学习到的东西转化函数，然后使用函数对单条数据进行预测。

那么我们如何把算法部署成 API 服务呢？ Byzer 核心理念如下：

我们可以把训练阶段的模型，udf，python/scala code 都转化为函数，然后串联函数就可以了。无需任何开发，就可以部署出一个端到端的 API 服务。

### 分析师同学的痛点看这里
分析师大部分都是写 SQL，hive script 其实 shell + SQL，这无形又需要分析师懂 shell 了， shell 是一门神奇的语言，主要是他不正规，没有标准委员会去约束。这是第一个痛点。

第二个痛点是啥呢， SQL 难以复用。 复用体现在几个层面：

1. 同一条 SQL 里有多个相同的 case when 语句，我得手写很多次。
2. SQL 表的复用，SQL 执行完一般就是一张表，如果我想复用这张表，那我就得写 hive 表，写 hive 表很痛苦，耗时并且占用存储，成本高。我能不能构建类似视图的东西呢？比如我需要A表，A 其实就是一条SQL，我需要的时候 include 这种 A 就好了。

第三个痛点是，我啥事都得靠你研发，比如处理一个东西依赖的UDF函数，都得等你研发搞。那我能不能自己用 Python 写一个UDF,不需要编译，不需要上线，还能复用呢？

这些问题如何解决呢？Byzer 的解决方式在这篇文章里 如何按程序员思维写分析师脚本

所有同学的痛点
所有同学的痛点，其实就是协作痛点。不同同学讲的语言不一样，你用 Java，我用 SQL，我用 Scala，我用 C++。 Byzer 怎么解决这个痛点呢？同一个语言，同一个平台。

Byzer 到底想干嘛
前面的数据中台概念里，我们提到了全公司数据视图，得益于我们底层依赖的 Spark，我们基本上可以 load 任何类型的数据源，所以你可以实现不挪动数据的情况，就可以把数仓里的数据，业务的数据库，甚至 execel 放在一起进行 join.

Byzer 就是想成为前面我们描述的一个数据中台，整合大数据和机器学习还有分析的所有流程。他的终极目标也很简单，让你的工作更轻松。


Q/A:

>Q1: 大中台还要能支持上层业务快速的灵活定制，上线，Byzer 能做到么？

A: Byzer 是一个脚本语言，无需编译和部署，调试完毕即可上线，所以天生适合上层业务的灵活性。我们举个如何用 Byzer 实现爬虫功能的例子来说明如何快速的满足业务需求。假设我们需要一个快速构建一个爬虫服务，但是 Byzer 自带的浏览器渲染功能满足不了诉求，这个时候我们可以开发一个浏览器渲染的服务，其 API 输入是 URL，输出是经过渲染后的 html。其他所有功能全部用 Byzer 来完成。实现上会是这个样子的：

```sql
set chrome_render_api="http:....."
load crawller.`http://www.csdn.net/blog/ai` where xpath=..... as url_table;
select http("${chrome_render_api}",map(......)) as html,url from url_table as htmls;
.......更多处理
---存储进数据库
save result as jdbc.`db.table`....
```
开发完毕后，如果有业务需求变更，直接更改脚本，然后发布，重新设置定时任务，基本上是 0 成本的，而且大家都看得懂。
