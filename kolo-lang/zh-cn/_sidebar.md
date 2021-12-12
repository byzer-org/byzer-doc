- Kolo-Lang Introduction
  * [Kolo-Lang](/kolo-lang/zh-cn/introduction/kolo_lang_intro.md)
  * [在线体验](/kolo-lang/zh-cn/introduction/byzer_lab.md)
  * [快速入门](/kolo-lang/zh-cn/introduction/get_started.md)
  * [常见问题 FAQ](/kolo-lang/zh-cn/appendix/faq.md)
  * [如何贡献](/kolo-lang/zh-cn/appendix/contribute.md)  

- 全新功能
  * [新功能](/kolo-lang/zh-cn/what's_new/new_features.md)

- 安装与配置
  * [Kolo-lang 安装与配置](/kolo-lang/zh-cn/installation/binary-installation.md)
  * [Kolo 桌面版](/kolo-lang/zh-cn/installation/desktop-installation.md)    
  * [Kolo 命令行](/kolo-lang/zh-cn/installation/cli-installation.md)
  * [Kolo Sandbox](/kolo-lang/zh-cn/installation/sandbox.md)

- Kolo-Lang 语法手册
  * [Kolo-Lang 语言向导](/kolo-lang/zh-cn/grammar/outline.md)
  * [数据加载/Load](/kolo-lang/zh-cn/grammar/load.md)
  * [数据转换/Select](/kolo-lang/zh-cn/grammar/select.md)
  * [保存数据/save](/kolo-lang/zh-cn/grammar/save.md)  
  * [扩展/Train|Run|Predict](/kolo-lang/zh-cn/grammar/et_statement.md)
  * [注册函数，模型/Register](/kolo-lang/zh-cn/grammar/register.md)  
  * [变量/Set](/kolo-lang/zh-cn/grammar/set.md)
  * [宏函数/Macro Function](/kolo-lang/zh-cn/grammar/macro.md)
  * [代码引入/Include](/kolo-lang/zh-cn/grammar/include.md)
  * [分支/If|Else](/kolo-lang/zh-cn/grammar/branch_statement.md)
  * [内置宏函数/build-in Macro Functions](/kolo-lang/zh-cn/grammar/commands.md)

- 数据处理和分析
    - 在 Kolo 中加载数据源
      * [数据源](/kolo-lang/zh-cn/datasource/README.md)
      * [RestAPI](/kolo-lang/zh-cn/datasource/restapi.md)
      * [JDBC](/kolo-lang/zh-cn/datasource/jdbc.md)
      * [ElasticSearch](/kolo-lang/zh-cn/datasource/es.md)
      * [Solr](/kolo-lang/zh-cn/datasource/solr.md)
      * [HBase](/kolo-lang/zh-cn/datasource/hbase.md)
      * [MongoDB](/kolo-lang/zh-cn/datasource/mongodb.md)
      * [Parquet/Json/Text/Xml/Csv](/kolo-lang/zh-cn/datasource/file.md)
      * [jsonStr/script/KoloAPI/KoloConf](/kolo-lang/zh-cn/datasource/kolo_source.md)
      * [Kafka](/kolo-lang/zh-cn/datasource/kafka.md)
      * [MockStreaming](/kolo-lang/zh-cn/datasource/mock_streaming.md)

    - 使用数仓/数据湖
        * [使用数仓/数据湖](/kolo-lang/zh-cn/datahouse/README.md)
        * [Hive加载和存储](/kolo-lang/zh-cn/datahouse/hive.md)
        * [Delta加载和存储以及流式支持](/kolo-lang/zh-cn/datahouse/delta_lake.md)
        * [MySQL Binlog同步](/kolo-lang/zh-cn/datahouse/mysql_binlog.md)

    - Python 扩展
        * [使用 Python 扩展 Kolo](/kolo-lang/zh-cn/python/README.md)
        * [环境依赖](/kolo-lang/zh-cn/python/env.md)
        * [数据处理](/kolo-lang/zh-cn/python/etl.md)
        * [模型训练](/kolo-lang/zh-cn/python/train.md)
        * [PyJava API简介](/kolo-lang/zh-cn/python/pyjava.md)
        * [结合Python读取Excel](/kolo-lang/zh-cn/python/read_excel.md)
        * [结合Python保存Excel](/kolo-lang/zh-cn/python/write_excel.md)
        * [K8s下的Python资源限制](/kolo-lang/zh-cn/python/k8s_resource.md)
        * [dataMode 详解](/kolo-lang/zh-cn/python/datamode.md)
        * [Python并行度你所需要知道的](/kolo-lang/zh-cn/python/py_parallel.md)

    * UDF 扩展
        * [使用 UDF 扩展 Kolo](/kolo-lang/zh-cn/udf/README.md)
        * [系统内置 UDF](/kolo-lang/zh-cn/udf/built_in_udf/README.md)
          * [http请求](/kolo-lang/zh-cn/udf/built_in_udf/http.md)
          * [常见函数](/kolo-lang/zh-cn/udf/built_in_udf/vec.md)
        * [动态扩展 UDF](/kolo-lang/zh-cn/udf/extend_udf.md)
          * [Python UDF](/kolo-lang/zh-cn/udf/python_udf.md)
          * [Scala UDF](/kolo-lang/zh-cn/udf/scala_udf.md)
          * [Scala UDAF](/kolo-lang/zh-cn/udf/scala_udaf.md)
          * [Java UDF](/kolo-lang/zh-cn/udf/java_udf.md)

    * Kolo 流编程
      * [使用 Kolo 处理流数据](/kolo-lang/zh-cn/streaming/README.md)
      * [Kolo Kafka Tools](/kolo-lang/zh-cn/streaming/kafka_tool.md)
      * [查询 Kafka 数据](/kolo-lang/zh-cn/streaming/query_kafka.md)
      * [设置流式计算回调](/kolo-lang/zh-cn/streaming/callback.md)
      * [对流的结果以批的形式保存](/kolo-lang/zh-cn/streaming/save_in_batch.md)
      * [使用 window/watermark](/kolo-lang/zh-cn/streaming/window_watermark.md)
      * [使用 Kolo 流式更新 MySQL 数据](/kolo-lang/zh-cn/streaming/stream_update_mysql.md)

- 机器学习
    * [特征工程](/kolo-lang/en-us/ml/feature/README.md)
        * [文本向量化](/kolo-lang/en-us/ml/feature/nlp/README.md)
            * [TFIDF](/kolo-lang/en-us/ml/feature/nlp/tfidf.md)
            * [Word2Vec](/kolo-lang/en-us/ml/feature/nlp/word2vec.md)
        * [特征平滑](/kolo-lang/en-us/ml/feature/scale.md)
        * [归一化](/kolo-lang/en-us/ml/feature/normalize.md)
        * [混淆矩阵](/kolo-lang/en-us/ml/feature/confusion_matrix.md)
        * [离散化](/kolo-lang/en-us/ml/feature/discretizer/README.md)
            * [Bucketizer](/kolo-lang/en-us/ml/feature/discretizer/bucketizer.md)
            * [Quantile](/kolo-lang/en-us/ml/feature/discretizer/quantile.md)
        * [Map转化为向量](/kolo-lang/en-us/ml/feature/vecmap.md)
        * [数据集切分](/kolo-lang/en-us/ml/feature/rate_sample.md)

    * [内置算法](/kolo-lang/en-us/ml/algs/README.md)
        * [AutoML](/kolo-lang/en-us/ml/algs/auto_ml.md) 
        * [KMeans](/kolo-lang/en-us/ml/algs/kmeans.md)
        * [NaiveBayes](/kolo-lang/en-us/ml/algs/naive_bayes.md)
        * [ALS](/kolo-lang/en-us/ml/algs/als.md)
        * [RandomForest](/kolo-lang/en-us/ml/algs/random_forest.md) 
        * [LogisticRegression](/kolo-lang/en-us/ml/algs/logistic_regression.md)
        * [LinearRegression](/kolo-lang/en-us/ml/algs/linear_regression.md)
        * [LDA](/kolo-lang/en-us/ml/algs/lda.md)

    * [部署算法 API 服务](/kolo-lang/en-us/ml/api_service/README.md)
        * [设计和原理](/kolo-lang/en-us/ml/api_service/design.md)
        * [部署流程](/kolo-lang/en-us/ml/api_service/process.md)

- 深度学习
    * [基于Java的深度学习框架集成](/kolo-lang/en-us/dl/README.md)
        * [加载图片数据](/kolo-lang/en-us/dl/load_image.md)
        * [Cifar10示例](/kolo-lang/en-us/dl/cifar10.md)

- 插件系统
    * [插件与安装](/kolo-lang/zh-cn/extension/README.md)
        * [插件商店](/kolo-lang/zh-cn/extension/installation/store.md)
        * [网络安装插件](/kolo-lang/zh-cn/extension/installation/online_install.md)
        * [离线安装插件](/kolo-lang/zh-cn/extension/installation/offline_install.md)
    * [Estimator-Transformer 插件](/kolo-lang/zh-cn/extension/et/README.md)
    * [DataSource 插件](/kolo-lang/zh-cn/extension/datasource/README.md)
        * [Excel 数据源插件](/kolo-lang/zh-cn/extension/datasource/excel.md)
        * [HBase 数据源](/kolo-lang/zh-cn/extension/datasource/hbase.md)


- 安全与权限
    * [接口访问控制](/kolo-lang/zh-cn/security/interface_acl/README.md)
    * [数据访问权限管理](/kolo-lang/zh-cn/security/data_acl/README.md)


- 开发者指南
    * 开发环境
      * [开发环境配置](/kolo-lang/zh-cn/developer/dev_env/README.md)
      * [Spark 2.4.3 开发环境](/kolo-lang/zh-cn/developer/dev_env/spark_2_4_3.md)
      * [Spark 3.0.0 开发环境](/kolo-lang/zh-cn/developer/dev_env/spark_3_0_0.md)    
    * 插件开发
      * [自定义 ET 插件开发](/kolo-lang/zh-cn/developer/extension/et_dev.md)
      * [自定义数据源插件开发](/kolo-lang/zh-cn/developer/extension/ds_dev.md)
    * [自动化测试用例开发](/kolo-lang/zh-cn/developer/it/integration_test.md)     
    * API
      * [Kolo Engine Rest API](/kolo-lang/zh-cn/developer/api/README.md)
        * [脚本执行 API](/kolo-lang/zh-cn/developer/api/run_script_api.md)
        * [代码提示 API](/kolo-lang/zh-cn/developer/api/code_suggest.md)
      * [Liveness API](/kolo-lang/zh-cn/developer/api/liveness.md)
      * [Readness API](/kolo-lang/zh-cn/developer/api/readiness.md)
    * [性能调优](/kolo-lang/zh-cn/developer/tunning/dynamic_resource.md)


- 附录
    * 发行声明
      * [Kolo 版本管理策略](/kolo-lang/zh-cn/appendix/release-notes/version.md)
      * [Kolo 2.2.0](/kolo-lang/zh-cn/appendix/release-notes/2.2.0.md)
      * [MLSQL Stack 2.1.0](/kolo-lang/zh-cn/appendix/release-notes/2.1.0.md)
      * [MLSQL Stack 2.0.1](/kolo-lang/zh-cn/appendix/release-notes/2.0.1.md)
      * [MLSQL Stack 2.0.0](/kolo-lang/zh-cn/appendix/release-notes/2.0.0.md)
    * [术语表](/kolo-lang/zh-cn/appendix/terms.md)  
    * [Blog](/kolo-lang/zh-cn/appendix/blog.md)   
