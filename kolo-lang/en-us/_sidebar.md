- Kolo-Lang Introduction
  * [Kolo-Lang](/kolo-lang/en-us/introduction/kolo_lang_intro.md)
  * [Online Trial](/kolo-lang/en-us/introduction/byzer_lab.md)
  * [Get Started](/kolo-lang/en-us/introduction/get_started.md)
  * [FAQ](/kolo-lang/en-us/appendix/faq.md)
  * [How to Contribute](/kolo-lang/en-us/appendix/contribute.md)  

- What's New
  * [New Features](/kolo-lang/en-us/what's_new/new_features.md)

- Installation
  * [Kolo Engine](/kolo-lang/en-us/installation/kolo_engine.md)
  * [Kolo Desktop](/kolo-lang/en-us/installation/kolo_desktop.md)    
  * [Kolo CLI](/kolo-lang/en-us/installation/kolo_cli.md)
  * [Kolo Sandbox](/kolo-lang/en-us/installation/sandbox.md)

- Grammar Manual
  * [Kolo-Lang Grammar](/kolo-lang/en-us/grammar/outline.md)
  * [Set Statement](/kolo-lang/en-us/grammar/set.md)
  * [Load Statement](/kolo-lang/en-us/grammar/load.md)
  * [Select Statement](/kolo-lang/en-us/grammar/select.md)
  * [Train/Run/Predict Statement](/kolo-lang/en-us/grammar/et_statement.md)
  * [Register Statement](/kolo-lang/en-us/grammar/register.md)
  * [Save Statement](/kolo-lang/en-us/grammar/save.md)
  * [Macro](/kolo-lang/en-us/grammar/macro.md)
  * [Include Statement](/kolo-lang/en-us/grammar/include.md)
  * [Branch Statement](/kolo-lang/en-us/grammar/branch_statement.md)
  * [Common Marco Commands](/kolo-lang/en-us/grammar/commands.md)

- Data Pipeline & Analysis
    - Load Datasource in Kolo
      * [Datasource](/kolo-lang/en-us/datasource/README.md)
      * [RestAPI](/kolo-lang/en-us/datasource/restapi.md)
      * [JDBC](/kolo-lang/en-us/datasource/jdbc.md)
      * [ElasticSearch](/kolo-lang/en-us/datasource/es.md)
      * [Solr](/kolo-lang/en-us/datasource/solr.md)
      * [HBase](/kolo-lang/en-us/datasource/hbase.md)
      * [MongoDB](/kolo-lang/en-us/datasource/mongodb.md)
      * [Parquet/Json/Text/Xml/Csv](/kolo-lang/en-us/datasource/file.md)
      * [jsonStr/script/KoloAPI/KoloConf](/kolo-lang/en-us/datasource/kolo_source.md)
      * [Kafka](/kolo-lang/en-us/datasource/kafka.md)
      * [MockStreaming](/kolo-lang/en-us/datasource/mock_streaming.md)

    - Data Warehouse / DataLake
        * [Data Warehouse / DataLake](/kolo-lang/en-us/datahouse/README.md)
        * [Load/Save in Hive](/kolo-lang/en-us/datahouse/hive.md)
        * [Delta lake](/kolo-lang/en-us/datahouse/delta_lake.md)
        * [MySQL Binlog](/kolo-lang/en-us/datahouse/mysql_binlog.md)

    - Extend with Python 
        * [Use Python to Extend Kolo](/kolo-lang/en-us/python/README.md)
        * [Environment](/kolo-lang/en-us/python/env.md)
        * [ETL](/kolo-lang/en-us/python/etl.md)
        * [Train](/kolo-lang/en-us/python/train.md)
        * [PyJava API Introduction](/kolo-lang/en-us/python/pyjava.md)
        * [Read Excel](/kolo-lang/en-us/python/read_excel.md)
        * [Write Excel](/kolo-lang/en-us/python/write_excel.md)
        * [Resource Restriction under K8S](/kolo-lang/en-us/python/k8s_resource.md)
        * [Datamode](/kolo-lang/en-us/python/datamode.md)
        * [Parallel in Python](/kolo-lang/en-us/python/py_parallel.md)

    * UDF Extension
        * [UDF in Kolo](/kolo-lang/en-us/udf/README.md)
        * [Built-In UDF](/kolo-lang/en-us/udf/built_in_udf/README.md)
          * [Http request](/kolo-lang/en-us/udf/built_in_udf/http.md)
          * [Common Functions](/kolo-lang/en-us/udf/built_in_udf/vec.md)
        * [Extend UDF](/kolo-lang/en-us/udf/extend_udf/README.md)
          * [Python UDF](/kolo-lang/en-us/udf/extend_udf/python_udf.md)
          * [Scala UDF](/kolo-lang/en-us/udf/extend_udf/scala_udf.md)
          * [Scala UDAF](/kolo-lang/en-us/udf/extend_udf/scala_udaf.md)
          * [Java UDF](/kolo-lang/en-us/udf/extend_udf/java_udf.md)

    * Streaming Processing
      * [Streaming Process](/kolo-lang/en-us/streaming/README.md)
      * [Kolo Kafka Tools](/kolo-lang/en-us/streaming/kafka_tool.md)
      * [Query from Kafka](/kolo-lang/en-us/streaming/query_kafka.md)
      * [Set Callback](/kolo-lang/en-us/streaming/callback.md)
      * [Save Result in Batch Mode](/kolo-lang/en-us/streaming/save_in_batch.md)
      * [Use window/watermark](/kolo-lang/en-us/streaming/window_watermark.md)
      * [Update MySQL data in stream](/kolo-lang/en-us/streaming/stream_update_mysql.md)

- Machine Learning
    * [Feature Engineering](/kolo-lang/en-us/ml/feature/README.md)
        * [NLP](/kolo-lang/en-us/ml/feature/nlp/README.md)
            * [TFIDF](/kolo-lang/en-us/ml/feature/nlp/tfidf.md)
            * [Word2Vec](/kolo-lang/en-us/ml/feature/nlp/word2vec.md)
        * [Feature Scaling](/kolo-lang/en-us/ml/feature/scale.md)
        * [Normalization](/kolo-lang/en-us/ml/feature/normalize.md)
        * [Confusion Matrix](/kolo-lang/en-us/ml/feature/confusion_matrix.md)
        * [Discretization](/kolo-lang/en-us/ml/feature/discretizer/README.md)
            * [Bucketizer](/kolo-lang/en-us/ml/feature/discretizer/bucketizer.md)
            * [Quantile](/kolo-lang/en-us/ml/feature/discretizer/quantile.md)
        * [Map to Vector](/kolo-lang/en-us/ml/feature/vecmap.md)
        * [Data Split](/kolo-lang/en-us/ml/feature/rate_sample.md)

    * [Built-In Algorithms](/kolo-lang/en-us/ml/algs/README.md)
        * [AutoML](/kolo-lang/en-us/ml/algs/auto_ml.md) 
        * [KMeans](/kolo-lang/en-us/ml/algs/kmeans.md)
        * [NaiveBayes](/kolo-lang/en-us/ml/algs/naive_bayes.md)
        * [ALS](/kolo-lang/en-us/ml/algs/als.md)
        * [RandomForest](/kolo-lang/en-us/ml/algs/random_forest.md) 
        * [LogisticRegression](/kolo-lang/en-us/ml/algs/logistic_regression.md)
        * [LinearRegression](/kolo-lang/en-us/ml/algs/linear_regression.md)
        * [LDA](/kolo-lang/en-us/ml/algs/lda.md)

    * [Deploy Algorithm as API Service](/kolo-lang/en-us/ml/api_service/README.md)
        * [Design and Principles](/kolo-lang/en-us/ml/api_service/design.md)
        * [Deploy Process](/kolo-lang/en-us/ml/api_service/process.md)

- Deep Learning
    * [Integration with Java DL Framework](/kolo-lang/en-us/dl/README.md)
        * [Load Images](/kolo-lang/en-us/dl/load_image.md)
        * [Cifar10 Example](/kolo-lang/en-us/dl/cifar10.md)
        

- Extension
    * [Extension Introduction](/kolo-lang/en-us/extension/README.md)
        * [Extension Store](/kolo-lang/en-us/extension/installation/store.md)
        * [Online Install](/kolo-lang/en-us/extension/installation/online_install.md)
        * [Offline Install](/kolo-lang/en-us/extension/installation/offline_install.md)
    * [Estimator-Transformer](/kolo-lang/en-us/extension/et/README.md)
    * [DataSource Extension](/kolo-lang/en-us/extension/datasource/README.md)
        * [Excel](/kolo-lang/en-us/extension/datasource/excel.md)
        * [HBase](/kolo-lang/en-us/extension/datasource/hbase.md)


- Security 
    * [Interface ACL](/kolo-lang/en-us/security/interface_acl/README.md)
    * [Data ACL](/kolo-lang/en-us/security/data_acl/README.md)

- Development
    * Dev Environment
      * [Dev Environment](/kolo-lang/en-us/developer/dev_env/README.md)
      * [Spark 2.4.3 Env](/kolo-lang/en-us/developer/dev_env/spark_2_4_3.md)
      * [Spark 3.0.0 Env](/kolo-lang/en-us/developer/dev_env/spark_3_0_0.md)    
    * Extension Development
      * [ET Development](/kolo-lang/en-us/developer/extension/et_dev.md)
      * [Datasource Extension Development](/kolo-lang/en-us/developer/extension/ds_dev.md)
    * [Integration Test](/kolo-lang/en-us/developer/it/integration_test.md)     
    * API
      * [Kolo Engine Rest API](/kolo-lang/en-us/developer/api/README.md)
        * [Script Run API](/kolo-lang/en-us/developer/api/run_script_api.md)
        * [Code Suggestion API](/kolo-lang/en-us/developer/api/code_suggest.md)
      * [Liveness API](/kolo-lang/en-us/developer/api/liveness.md)
      * [Readness API](/kolo-lang/en-us/developer/api/readiness.md)
    * [Performance Tunning](/kolo-lang/en-us/developer/tunning/dynamic_resource.md)


- Appendix
    * Release
      * [Kolo Version Management](/kolo-lang/en-us/appendix/release-notes/version.md)
      * [Kolo 2.2.0](/kolo-lang/en-us/appendix/release-notes/2.2.0.md)
      * [MLSQL Stack 2.1.0](/kolo-lang/en-us/appendix/release-notes/2.1.0.md)
      * [MLSQL Stack 2.0.1](/kolo-lang/en-us/appendix/release-notes/2.0.1.md)
      * [MLSQL Stack 2.0.0](/kolo-lang/en-us/appendix/release-notes/2.0.0.md)
    * [Terms](/kolo-lang/en-us/appendix/terms.md)  
    * [Blog](/kolo-lang/en-us/appendix/blog.md)   


