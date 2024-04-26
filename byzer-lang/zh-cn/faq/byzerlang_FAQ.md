# Byzer-lang FAQ

### 基本概念与问答

#### Q1.1 ：什么是 Byzer

Byzer 则是一个Data+AI 数据库。
Byzer-SQL 是运行于 Byzer之上的面向 Data 和 AI 的低代码、云原生的支持大模型部署和使用的编程语言。

#### Q1.1.1 ：Byzer数据库运行时包括 Spark引擎,那它和 Spark 有什么区别

Byzer 不等于 Spark。 

首先， Byzer 的物理执行引擎是基于Hybrid Runtime，也就是Spark+Ray，从而满足大数据ETL， 数据分析，机器学习，大模型支持等更加全面的特性支持。此外， 该 Hybrid Runtime 支持多租户，这也有别于传统一个用户独占一Spark实例的做法。

其次，Byzer提供了一套完整的SQL方言：Byzer-SQL，可以通过纯 SQL 的方式完成 ETL, 数据分析，机器学习，大模型微调，部署和使用，并且语言可扩展，随时可以添加新的插件。

此外，Byzer 六年积累了大量插件，可以满足用户多种多样的需求，而这些如果使用原生Spark，可能都需要用户自己开发。

相比传统 Jupyter 等面向 Python 为主 SQL 为辅的编辑器， Byzer 还提供了一套 SQL 为一等公民的 Byzer-Notebook，并且内置了 DolphinScheduler调度支持。非常适合ETL工程师，数据分析师使用SQL调试脚本，即时做数据分析。

对于需要构建自己产品的公司，基于 Byzer, 可以不需要大数据相关的工程师，只需要开发web产品，然后根据业务需求拼接 Byzer-SQL ,和传统 web开发完全一致，即可完成大数据产品，机器学习产品的开发，相比直接使用Spark，需要大量懂Spark研发的同学而言，优势非常大。


#### Q1.2：Byzer 的技术方向和核心能力是什么？

通过一个语言来帮助用户获取 Data + AI 工作所需要的所有能力。


#### Q1.3：Byzer 要帮企业解决的痛点是什么？

**企业痛点：**

- 数据和 AI 的使用成本高，ROI低，收益难以抵消成本

- 缺少ML专家，就算不考虑成本，也很难找到足够符合要求的人

- 机器学习实操困难，模型和场景难结合

- ML训练工作流复杂且重复，难以维护部署

**Goal: 降低企业落地 Data + AI 的门槛和成本**

#### Q 1.4 什么是 Byzer 的 ET？

**ET** 是 Byzer 语言内置 Estimator/Transformer 的简称。

Byzer 内置了非常多的 Estimator/Transformer 帮助用户去解决一些用 SQL 难以解决的问题。

通常而言，Estimator 会学习数据，并且产生一个模型。而 Transformer 则是纯粹的数据处理。通常我们认为算法是一个 Estimator，而算法训练后产生 的模型则是 Transformer。大部分数据处理都是 Transformer，SQL 中的 select 语句也是一种特殊的 Transformer。

ET主要涵盖：

1. 无法用 SQL 实现的特定的数据处理
2. 实现各种可复用的复杂的算法模型以及特征工程工具
3. 提供各种便利工具，比如发送邮件，生成图片等各种必须的工具

所以总结起来，ET 是 Byzer 中提供的一种黑盒工具，方便我们使用 SQL 一站式解决模型和数据处理的业务问题。


### 和其他编程语言对比

#### Q2.1：Byzer与 SQL/Python/PySpark 之类的什么不同呢？

1. **和 SQL 相比**

Byzer 语法非常像 SQL，可以理解为是以 SQL 语法打底的一个新语言。我们在原生 SQL 语法的基础上提供了非常强大的可编程能力，这主要体现在我们可以像传统编程语言一样组织 Byzer 代码，这包括：

- 命令行支持

- 脚本化

- 支持引用

- 支持第三方模块

- 支持模板

- 支持函数定义

- 支持分支语句

所以和 SQL 相比，我们可以理解为 Byzer 是一个可编程的 SQL。



2. **和 Python 相比**

**相比 Python，Byzer 是一个天生支持分布式的语言，但同时也具备强大的可编程能力。**但是我们知道 Byzer 是同时面向大数据和 AI 的分布式语言，而 Byzer 尽管功能强大，但对算法的支持默认是需要使用 Java/Scala 开发的 native 插件来完成的。

同时，为了能够拥抱现有的 Python AI 生态，所以 Byzer 需要也必须提供支持运行 Python 脚本能力，Python 是作为寄生语言存在于 Byzer 当中。Byzer 通过 pyjava 库，让 Python 脚本可以访问到 Byzer 产生的临时表（在 Byzer 中，模型也可以存储成表），也可以让 Byzer 宿主语言获取 Python 的结果。



3. **和 PySpark 相比**

PySpark 是 Spark 为 Python 开发者提供的 API。但 Pyspark 自身能力有限制，且有一定学习门槛。

而 Byzer 通过引入 Ray，给 Python 提供了分布式编程能力，从而使得整个语言都是分布式的。Ray 的高性能分布式执行框架使用了和传统分布式计算系统不一样的架构和对分布式计算的抽象方式，具有比 Spark 更优异的计算性能。



### Byzer 引擎相关

#### Q3.1 Byzer 与 spark 如何交互，比如 load \ select \ save 的处理过程 

Byzer-lang 提供了 Rest 接口执行 Byzer 代码的能力。 入口为 `streaming.rest.RestController.script` 方法，该方法的接口为  `/run/script`

该方法大致有如下几个流程：

1. 根据用户以及策略创建或者获取已有的 SparkSession
2. 鉴权
3. 创建 Context(ThreadLocal对象，方便在线程内传递数据)
4. 执行脚本 ScriptSQLExec.*parse*
5. 同步或者异步返回结果



其中真正执行脚本的是 streaming.dsl.`ScriptSQLExec.parse`*.这个方法是整个解释器的核心。*

它会执行如下逻辑：

1. 对脚本进行预处理。类似 C 语言，主要是对 include 语句进行处理，链接相关脚本。目前支持最多10层 include 嵌套。但随着未来 Byzer 第三方库的发展，该限制会调大，并且用户可自由配置。
2. 对变量以及宏函数进行预处理。比如把宏函数展开成实际 byzer-lang 代码调用，同时把常量变量都进行 evaluate 操作，比如在 load 语句中对常量的应用也都会变成实际的值。
3. 语法校验。到这一步，已经是一个单一的大脚本，而且去掉了语法糖。此时可以进行语法校验。
4. 解析时权限校验。此时已经对每个语句进行权限校验了。比如什么用户load 了什么数据是不是被允许。
5. 物理执行。对每个语句进行实际的执行动作。此时会有运行时权限校验，同时产生表。



物理执行阶段，Byzer-lang 使用了 Antlrv4 的 vistitor 模式，代码大致如下：

```Scala
val PREFIX = ctx.getChild(0).getText.toLowerCase()

before(PREFIX)

PREFIX match {

  case "load" =>

    val adaptor = new LoadAdaptor(this)

    execute(adaptor)
  
  case "select" =>

    val adaptor = new SelectAdaptor(this)

    execute(adaptor)

  case "save" =>

    val adaptor = new SaveAdaptor(this)

    execute(adaptor)

  case "connect" =>

    val adaptor = new ConnectAdaptor(this)

    execute(adaptor)

  case "create" =>

    val adaptor = new CreateAdaptor(this)

    execute(adaptor)

  case "insert" =>

    val adaptor = new InsertAdaptor(this)

    execute(adaptor)

  case "drop" =>

    val adaptor = new DropAdaptor(this)
```



可以看到，针对已经处理的好的脚本，我们会通过第一个关键字进行匹配，找到合适的 Adaptor, Adaptor负责解析和执行这条语句。如果用户需要实现自己的 Adaptor（新语法）,除了修改 streamingpro-dsl 里的语法描述文件以外，还要实现对应的 Adaptor。我们以 LoadAaptor 为例，用户只需要实现 `tech.mlsql.dsl.adaptor.DslAdaptor` 接口即可。

```Scala
class LoadAdaptor(scriptSQLExecListener: ScriptSQLExecListener) extends DslAdaptor {

  def evaluate(value: String) = {

    TemplateMerge.merge(value, scriptSQLExecListener.env().toMap)

  }


  def analyze(ctx: SqlContext): LoadStatement = {

    var format = ""

    var option = Map[String, String]()

    var path = ""

    var tableName = ""

    (0 to ctx.getChildCount() - 1).foreach { tokenIndex =>

      ctx.getChild(tokenIndex) match {

        case s: FormatContext =>

          format = s.getText

        case s: ExpressionContext =>

          option += (cleanStr(s.qualifiedName().getText) -> evaluate(getStrOrBlockStr(s)))

        case s: BooleanExpressionContext =>

          option += (cleanStr(s.expression().qualifiedName().getText) -> evaluate(getStrOrBlockStr(s.expression())))

        case s: PathContext =>

          path = s.getText

        case s: TableNameContext =>

          tableName = evaluate(s.getText)

        case _ =>

      }

    }

    LoadStatement(currentText(ctx), format, path, option, tableName)

  }

  override def parse(ctx: SqlContext): Unit = {

    val LoadStatement(_, format, path, option, tableName) = analyze(ctx)

    def isStream = {

      scriptSQLExecListener.env().contains("streamName")

    }

    if (isStream) {

      scriptSQLExecListener.addEnv("stream", "true")

    }

    new LoadProcessing(scriptSQLExecListener, option, path, tableName, format).parse
    
    scriptSQLExecListener.setLastSelectTable(tableName)
  }

}
```

analyze方法 实现语法解析，抽取出必要的信息， parse 根据这些抽取的信息，转化成 Spark/Ray 能执行的代码。

对于条件分支语句中的表达式，则是单独实现，参考 streamingpro-core 模块中的 `tech.mlsql.lang.cmd.compile.internal.gc` 包下的文件。


#### Q3.2：Byzer 如何屏蔽不同数据库的语法差异？

首先，在默认情况下，引擎仅仅会下推 filter 算子,其他部分都是在引擎中进行计算，所以一般只要数据库是遵循 JDBC 标准或者实现 Spark Datasource 接口即可。

其次，对于聚合下推，因为 Byzer 会把下推 AST 子树转换成对应数据库原生的 SQL 语言，所以需要Dialect（方言）。目前已经支持 Kylin/MySQL（截止到2.2.0版本，暂时只支持基于Spark 2.4.3 ）。

基本原理是，将 Byzer-lang 转化为为单一 AST,然后将涉及到的某个数据库实例下的 AST 子树（比如对某个实例的子查询）转化为对应数据库方言，发送给底层执行，将底层执行结果映射成一个 JDBC 数据集，然后转换成新的节点重新更新到 AST 上，最后执行 AST。



代码位于 external/mlsql-sql-profiler/src/main/java/tech/mlsql/indexer/impl下。使用建议参考：[Byzer 支持 JDBC 聚合下推](/public/blog_archive_2021/Byzer支持JDBC聚合下推.md)

最后，我们也提供了 DirectQuery, 允许用户直接使用原生的数据库查询语句。https://docs.byzer.org/#/byzer-lang/zh-cn/grammar/load?id=直接查询模式directquery



#### Q3.3：当返回大量数据时，前端如何处理？引擎本身是否提供批量获取？

引擎端默认是返回 5000 条记录，可以通过 http 请求参数控制（也就是比如 Byzer Notebook 每次请求时都可以设置返回的结果数据最大限制条数）。

目前没有提供批量数据获取。我们推荐的方案是使用 byzer-lang 将数据保存成合适的格式到某个路径，然后提供下载服务地址来完成批量数据导出，这种方式稳定可靠，对引擎端没什么压力。





