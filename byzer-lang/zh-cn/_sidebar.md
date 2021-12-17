- Byzer-Lang Introduction
  * [Byzer-Lang](/byzer-lang/zh-cn/introduction/kolo_lang_intro.md)
  * [在线试用](/byzer-lang/zh-cn/introduction/online_trial.md)
  * [快速开始](/byzer-lang/zh-cn/introduction/get_started.md)
  * [常见问题 FAQ](/byzer-lang/zh-cn/appendix/faq/README.md)
    * [听说mlsql-cluster暂时不更新了，mlsql-cluster是个啥？](/byzer-lang/zh-cn/appendix/faq/mlsql-cluster.md)
    * [MLSQL K8s部署，镜像环境如何制作](/byzer-lang/zh-cn/appendix/faq/mlsql-k8s-build.md)
    * [加载JDBC(如MySQL，Oracle)数据常见困惑](/byzer-lang/zh-cn/appendix/faq/jdbc.md)
  * [如何贡献](/byzer-lang/zh-cn/appendix/contribute.md)  

- 全新功能
  * [新功能](/byzer-lang/zh-cn/what's_new/new_features.md)

- 安装与配置
  * [Byzer-lang 安装与配置](/byzer-lang/zh-cn/installation/binary-installation.md)
  * [Byzer 桌面版](/byzer-lang/zh-cn/installation/desktop-installation.md)    
  * [Byzer 命令行](/byzer-lang/zh-cn/installation/cli-installation.md)
  * [Byzer Sandbox](/byzer-lang/zh-cn/installation/sandbox.md)

- Byzer-Lang 语法手册
  * [Byzer-Lang 语言向导](/byzer-lang/zh-cn/grammar/outline.md)
  * [数据加载/Load](/byzer-lang/zh-cn/grammar/load.md)
  * [数据转换/Select](/byzer-lang/zh-cn/grammar/select.md)
  * [保存数据/save](/byzer-lang/zh-cn/grammar/save.md)  
  * [扩展/Train|Run|Predict](/byzer-lang/zh-cn/grammar/et_statement.md)
  * [注册函数，模型/Register](/byzer-lang/zh-cn/grammar/register.md)  
  * [变量/Set](/byzer-lang/zh-cn/grammar/set.md)
  * [宏函数/Macro Function](/byzer-lang/zh-cn/grammar/macro.md)
  * [代码引入/Include](/byzer-lang/zh-cn/grammar/include.md)
  * [分支/If|Else](/byzer-lang/zh-cn/grammar/branch_statement.md)
  * [内置宏函数/build-in Macro Functions](/byzer-lang/zh-cn/grammar/commands.md)

- 数据处理和分析
    - [加载和存储多种数据源](/byzer-lang/zh-cn/datasource/README.md)
      * [RestAPI](/byzer-lang/zh-cn/datasource/restapi.md)
      * [JDBC](/byzer-lang/zh-cn/datasource/jdbc.md)
      * [ElasticSearch](/byzer-lang/zh-cn/datasource/es.md)
      * [Solr](/byzer-lang/zh-cn/datasource/solr.md)
      * [HBase](/byzer-lang/zh-cn/datasource/hbase.md)
      * [MongoDB](/byzer-lang/zh-cn/datasource/mongodb.md)
      * [本地文件/HDFS](/byzer-lang/zh-cn/datasource/file.md)
      * [内置数据源](/byzer-lang/zh-cn/datasource/kolo_source.md)
      * [Kafka](/byzer-lang/zh-cn/datasource/kafka.md)
      * [MockStreaming](/byzer-lang/zh-cn/datasource/mock_streaming.md)
      * [其他](/byzer-lang/zh-cn/datasource/other.md)

    - [使用数仓/数据湖](/byzer-lang/zh-cn/datahouse/README.md)
        * [Hive加载和存储](/byzer-lang/zh-cn/datahouse/hive.md)
        * [Delta加载和存储以及流式支持](/byzer-lang/zh-cn/datahouse/delta_lake.md)
        * [MySQL Binlog同步](/byzer-lang/zh-cn/datahouse/mysql_binlog.md)

    - [Byzer-python](/byzer-lang/zh-cn/python/README.md)
        * [环境依赖](/byzer-lang/zh-cn/python/env.md)
        * [数据处理](/byzer-lang/zh-cn/python/etl.md)
        * [模型训练](/byzer-lang/zh-cn/python/train.md)
        * [模型部署](/byzer-lang/zh-cn/python/deploy_model.md)
        * [PyJava API简介](/byzer-lang/zh-cn/python/pyjava.md)
        * [k8s 下的 Byzer-python 资源限制](/byzer-lang/zh-cn/python/k8s_resource.md)
        * [dataMode 详解](/byzer-lang/zh-cn/python/datamode.md)
        * [Byzer-python 并行度](/byzer-lang/zh-cn/python/py_parallel.md)
    
    * [UDF 扩展](/byzer-lang/zh-cn/udf/README.md)
        * [系统内置 UDF](/byzer-lang/zh-cn/udf/built_in_udf/README.md)
          * [http请求](/byzer-lang/zh-cn/udf/built_in_udf/http.md)
          * [常用函数](/byzer-lang/zh-cn/udf/built_in_udf/vec.md)
        * [动态扩展 UDF](/byzer-lang/zh-cn/udf/extend_udf/README.md)
          * [Python UDF](/byzer-lang/zh-cn/udf/extend_udf/python_udf.md)
          * [Scala UDF](/byzer-lang/zh-cn/udf/extend_udf/scala_udf.md)
          * [Scala UDAF](/byzer-lang/zh-cn/udf/extend_udf/scala_udaf.md)
          * [Java UDF](/byzer-lang/zh-cn/udf/extend_udf/java_udf.md)
    
    * [Byzer 流编程](/byzer-lang/zh-cn/streaming/README.md)
      * [Byzer Kafka Tools](/byzer-lang/zh-cn/streaming/kafka_tool.md)
      * [查询 Kafka 数据](/byzer-lang/zh-cn/streaming/query_kafka.md)
      * [设置流式计算回调](/byzer-lang/zh-cn/streaming/callback.md)
      * [对流的结果以批的形式保存](/byzer-lang/zh-cn/streaming/save_in_batch.md)
      * [使用 window/watermark](/byzer-lang/zh-cn/streaming/window_watermark.md)
      * [使用 Byzer 流式更新 MySQL 数据](/byzer-lang/zh-cn/streaming/stream_update_mysql.md)
    
- 机器学习
    * [特征工程](/byzer-lang/zh-cn/ml/feature/README.md)
        * [文本向量化](/byzer-lang/zh-cn/ml/feature/nlp/README.md)
            * [TFIDF](/byzer-lang/zh-cn/ml/feature/nlp/tfidf.md)
            * [Word2Vec](/byzer-lang/zh-cn/ml/feature/nlp/word2vec.md)
        * [特征平滑](/byzer-lang/zh-cn/ml/feature/scale.md)
        * [归一化](/byzer-lang/zh-cn/ml/feature/normalize.md)
        * [混淆矩阵](/byzer-lang/zh-cn/ml/feature/confusion_matrix.md)
        * [离散化](/byzer-lang/zh-cn/ml/feature/discretizer/README.md)
            * [Bucketizer](/byzer-lang/zh-cn/ml/feature/discretizer/bucketizer.md)
            * [Quantile](/byzer-lang/zh-cn/ml/feature/discretizer/quantile.md)
        * [Map转化为向量](/byzer-lang/zh-cn/ml/feature/vecmap.md)
        * [数据集切分](/byzer-lang/zh-cn/ml/feature/rate_sample.md)

    * [内置算法](/byzer-lang/zh-cn/ml/algs/README.md)
        * [AutoML](/byzer-lang/zh-cn/ml/algs/auto_ml.md) 
        * [KMeans](/byzer-lang/zh-cn/ml/algs/kmeans.md)
        * [NaiveBayes](/byzer-lang/zh-cn/ml/algs/naive_bayes.md)
        * [ALS](/byzer-lang/zh-cn/ml/algs/als.md)
        * [RandomForest](/byzer-lang/zh-cn/ml/algs/random_forest.md) 
        * [LogisticRegression](/byzer-lang/zh-cn/ml/algs/logistic_regression.md)
        * [LinearRegression](/byzer-lang/zh-cn/ml/algs/linear_regression.md)
        * [LDA](/byzer-lang/zh-cn/ml/algs/lda.md)

    * [部署算法 API 服务](/byzer-lang/zh-cn/ml/api_service/README.md)
        * [设计和原理](/byzer-lang/zh-cn/ml/api_service/design.md)
        * [部署流程](/byzer-lang/zh-cn/ml/api_service/process.md)

- 深度学习
    * [基于Java的深度学习框架集成](/byzer-lang/zh-cn/dl/README.md)
        * [加载图片数据](/byzer-lang/zh-cn/dl/load_image.md)
        * [Cifar10示例](/byzer-lang/zh-cn/dl/cifar10.md)

- 插件系统
    * [插件与安装](/byzer-lang/zh-cn/extension/README.md)
        * [插件商店](/byzer-lang/zh-cn/extension/installation/store.md)
        * [网络安装插件](/byzer-lang/zh-cn/extension/installation/online_install.md)
        * [离线安装插件](/byzer-lang/zh-cn/extension/installation/offline_install.md)
    * [Estimator-Transformer 插件](/byzer-lang/zh-cn/extension/et/README.md)
    * [DataSource 插件](/byzer-lang/zh-cn/extension/datasource/README.md)
        * [Excel 数据源插件](/byzer-lang/zh-cn/extension/datasource/excel.md)
        * [HBase 数据源](/byzer-lang/zh-cn/extension/datasource/hbase.md)


- 安全与权限
  * [接口访问控制](/byzer-lang/zh-cn/security/interface_acl/README.md)
  * [数据访问权限管理](/byzer-lang/zh-cn/security/data_acl/README.md)

- 开发者指南
    * [开发环境配置](/byzer-lang/zh-cn/developer/dev_env/README.md)
      * [Spark 2.4.3 开发环境](/byzer-lang/zh-cn/developer/dev_env/spark_2_4_3.md)
      * [Spark 3.0.0 开发环境](/byzer-lang/zh-cn/developer/dev_env/spark_3_0_0.md)    
    * 插件开发
      * [自定义 ET 插件开发](/byzer-lang/zh-cn/developer/extension/et_dev.md)
      * [自定义数据源插件开发](/byzer-lang/zh-cn/developer/extension/ds_dev.md)
    * [自动化测试用例开发](/byzer-lang/zh-cn/developer/it/integration_test.md)     
    * API
      * [Byzer Engine Rest API](/byzer-lang/zh-cn/developer/api/README.md)
        * [脚本执行 API](/byzer-lang/zh-cn/developer/api/run_script_api.md)
        * [代码提示 API](/byzer-lang/zh-cn/developer/api/code_suggest.md)
      * [Liveness API](/byzer-lang/zh-cn/developer/api/liveness.md)
      * [Readness API](/byzer-lang/zh-cn/developer/api/readiness.md)
    * [性能调优](/byzer-lang/zh-cn/developer/tunning/dynamic_resource.md)


- 附录
  * 发行声明
    * [Byzer 版本管理策略](/byzer-lang/zh-cn/appendix/release-notes/version.md)
    * [Byzer 2.2.0](/byzer-lang/zh-cn/appendix/release-notes/2.2.0.md)
    * [MLSQL Stack 2.1.0](/byzer-lang/zh-cn/appendix/release-notes/2.1.0.md)
    * [MLSQL Stack 2.0.1](/byzer-lang/zh-cn/appendix/release-notes/2.0.1.md)
    * [MLSQL Stack 2.0.0](/byzer-lang/zh-cn/appendix/release-notes/2.0.0.md)
  * [术语表](/byzer-lang/zh-cn/appendix/terms.md)  
  * [Blog](/byzer-lang/zh-cn/appendix/blog.md)   
  * [取名小故事](/byzer-lang/zh-cn/appendix/naming_story.md)   
