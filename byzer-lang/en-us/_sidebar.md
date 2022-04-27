- Byzer-Lang Introduction
  * [Byzer-Lang](/byzer-lang/en-us/introduction/byzer_lang_intro.md)
  * [Byzer-Lang Design](/byzer-lang/en-us/introduction/byzer_lang_design.md)
  * [Online Trial](/byzer-lang/en-us/introduction/online_trial.md)
  * [How to Contribute](/byzer-lang/en-us/appendix/contribute.md)  
  * [FAQ](/byzer-lang/en-us/faq/byzerlang_FAQ.md)

- Release Notes
  * [Byzer Version Management](/byzer-lang/en-us/release-notes/README.md)
  * [Byzer-lang 2.3.0](/byzer-lang/en-us/release-notes/2.3.0.md)
  * [Byzer-lang 2.2.2](/byzer-lang/en-us/release-notes/2.2.2.md)
  * [Byzer-lang 2.2.1](/byzer-lang/en-us/release-notes/2.2.1.md)
  * [Byzer-lang 2.2.0](/byzer-lang/en--us/release-notes/2.2.0.md)

- Installation
  * [Byzer-lang Installation Instruction](/byzer-lang/en-us/installation/README.md)
  * [Byzer All In One Deployment](/byzer-lang/en-us/installation/server/byzer-all-in-one-deployment.md)
  * [Byzer Server Deployment](/byzer-lang/en-us/installation/server/binary-installation.md)
  * [Containerized Deployment](/byzer-lang/en-us/installation/containerized-deployment/containerized-deployment.md)
    * [Sandbox Deployment](/byzer-lang/en-us/installation/containerized-deployment/sandbox-standalone.md)
    * [Multi-container Deployment](/byzer-lang/en-us/installation/containerized-deployment/muti-continer.md)
  * [K8S Deployment](/byzer-lang/en-us/installation/k8s/k8s-deployment.md)
    * [On Minikube](/byzer-lang/en-us/installation/k8s/byzer-on-minikube.md)
    * [Byzer-K8S Tools](/byzer-lang/en-us/installation/k8s/byzer-k8s-tool.md)
  * [Byzer VSCode Extension](/byzer-lang/en-us/installation/vscode/byzer-vscode-extension-installation.md)
  * [Byzer Engine Properties](/byzer-lang/en-us/installation/configuration/byzer-lang-configuration.md)
  
- Byzer-lang Grammar Manual
  * [Byzer-Lang Guide](/byzer-lang/en-us/grammar/outline.md)  
  * [Data Load/Load](/byzer-lang/en-us/grammar/load.md)
  * [Data Transform/Select](/byzer-lang/en-us/grammar/select.md)
  * [Data Save/Save](/byzer-lang/en-us/grammar/save.md)
  * [Extension/Train|Run|Predict](/byzer-lang/en-us/grammar/et_statement.md)
  * [Model,UDF Register/Register](/byzer-lang/en-us/grammar/register.md)  
  * [Variable/Set](/byzer-lang/en-us/grammar/set.md)
  * [Macro Function](/byzer-lang/en-us/grammar/macro.md)
  * [Code Import/Include](/byzer-lang/en-us/grammar/include.md)
  * [Branch/If|Else](/byzer-lang/en-us/grammar/branch_statement.md)
  * [Build-in Marco Functions](/byzer-lang/en-us/grammar/commands.md)

- Data Pipeline & Analysis
    - [Load Datasource in Byzer](/byzer-lang/en-us/datasource/README.md)
      * [RestAPI](/byzer-lang/en-us/datasource/restapi.md)
        * [More REST API Examples](/byzer-lang/en-us/datasource/restapi_examples.md)
      * [JDBC](/byzer-lang/en-us/datasource/jdbc.md)
      * [ElasticSearch](/byzer-lang/en-us/datasource/es.md)
      * [Solr](/byzer-lang/en-us/datasource/solr.md)
      * [HBase](/byzer-lang/en-us/datasource/hbase.md)
      * [MongoDB](/byzer-lang/en-us/datasource/mongodb.md)
      * [Parquet/Json/Text/Xml/Csv](/byzer-lang/en-us/datasource/file.md)
      * [Kafka](/byzer-lang/en-us/datasource/kafka.md)
      * [MockStream](/byzer-lang/en-us/datasource/mock_streaming.md)
      * [Others](/byzer-lang/en-us/datasource/other.md)

    - [Data Warehouse / DataLake](/byzer-lang/en-us/datahouse/README.md)
        * [Load/Save in Hive](/byzer-lang/en-us/datahouse/hive.md)
        * [Delta lake](/byzer-lang/en-us/datahouse/delta_lake.md)
        * [MySQL Binlog](/byzer-lang/en-us/datahouse/mysql_binlog.md)

    - [Byzer-python](/byzer-lang/en-us/python/README.md)
        * [Environment](/byzer-lang/en-us/python/env.md)
        * [Data Process](/byzer-lang/en-us/python/etl.md)
        * [Train](/byzer-lang/en-us/python/train.md)
        * [Deploy](/byzer-lang/en-us/python/deploy_model.md)
        * [PyJava API Introduction](/byzer-lang/en-us/python/pyjava.md)
        * [Resource Restriction under K8S](/byzer-lang/en-us/python/k8s_resource.md)
        * [Datamode](/byzer-lang/en-us/python/datamode.md)
        * [Parallel in Byzer-python](/byzer-lang/en-us/python/py_parallel.md)

    * [UDF Extension](/byzer-lang/en-us/udf/README.md)
        * [Built-In UDF](/byzer-lang/en-us/udf/built_in_udf/README.md)
          * [Http request](/byzer-lang/en-us/udf/built_in_udf/http.md)
          * [Common Functions](/byzer-lang/en-us/udf/built_in_udf/vec.md)
        * [Extend UDF](/byzer-lang/en-us/udf/extend_udf/README.md)
          * [Python UDF](/byzer-lang/en-us/udf/extend_udf/python_udf.md)
          * [Scala UDF](/byzer-lang/en-us/udf/extend_udf/scala_udf.md)
          * [Scala UDAF](/byzer-lang/en-us/udf/extend_udf/scala_udaf.md)
          * [Java UDF](/byzer-lang/en-us/udf/extend_udf/java_udf.md)

- Machine Learning
    * [Feature Engineering](/byzer-lang/en-us/ml/feature/README.md)
        * [ScalerPlace](/byzer-lang/en-us/ml/feature/scale.md)
        * [NormalizeInPlace](/byzer-lang/en-us/ml/feature/normalize.md)
        * [ConfusionMatrix](/byzer-lang/en-us/ml/feature/confusion_matrix.md)
        * [RateSampler](/byzer-lang/en-us/ml/feature/rate_sample.md)

    * [Built-In Algorithms](/byzer-lang/en-us/ml/algs/README.md)
        * [AutoML](/byzer-lang/en-us/ml/algs/auto_ml.md) 
        * [KMeans](/byzer-lang/en-us/ml/algs/kmeans.md)
        * [NaiveBayes](/byzer-lang/en-us/ml/algs/naive_bayes.md)
        * [ALS](/byzer-lang/en-us/ml/algs/als.md)
        * [RandomForest](/byzer-lang/en-us/ml/algs/random_forest.md) 
        * [LogisticRegression](/byzer-lang/en-us/ml/algs/logistic_regression.md)
        * [LinearRegression](/byzer-lang/en-us/ml/algs/linear_regression.md)
        * [LDA](/byzer-lang/en-us/ml/algs/lda.md)

    * [Deploy Algorithm as API Service](/byzer-lang/en-us/ml/api_service/README.md)
        * [Design and Principles](/byzer-lang/en-us/ml/api_service/design.md)
        * [Deploy Process](/byzer-lang/en-us/ml/api_service/process.md)

- Extension
    * Extension Development
      * [ET Development](/byzer-lang/en-us/extension/dev/et_dev.md)
      * [Command Development](/byzer-lang/en-us/extension/dev/et_command.md)
      * [Datasource Extension Development](/byzer-lang/en-us/extension/dev/ds_dev.md)
      * [Introduction to parameter introspection mechanism](/byzer-lang/en-us/extension/dev/et_params_dev.md)
    * [Extension Installation](/byzer-lang/en-us/extension/README.md)
        * [Online Install](/byzer-lang/en-us/extension/installation/online_install.md)
        * [Offline Install](/byzer-lang/en-us/extension/installation/offline_install.md)
    * [Estimator-Transformer](/byzer-lang/en-us/extension/et/README.md)
        * Built-in ET
            * [How to cache table](/byzer-lang/en-us/extension/et/CacheExt.md)
            * [Direct MySQL operation](/byzer-lang/en-us/extension/et/JDBC.md)
            * [Use of Json Expansion Plug-in](/byzer-lang/en-us/extension/et/JsonExpandExt.md)
            * [Use of Byzer-Watcher plug-in](/byzer-lang/en-us/extension/et/byzer-watcher.md)
            * [How to send mail](/byzer-lang/en-us/extension/et/SendMessage.md)
            * [Syntax Analysis Tool](/byzer-lang/en-us/extension/et/SyntaxAnalyzeExt.md)
            * [Change the number of partitions of the table](/byzer-lang/en-us/extension/et/TableRepartition.md)
            * [Calculate complex parent-child relationship](/byzer-lang/en-us/extension/et/TreeBuildExt.md)
        * External ET
            * [Connect statement persistence](/byzer-lang/en-us/extension/et/external/connect-persist.md)
            * [Byzer assertion](/byzer-lang/en-us/extension/et/external/mlsql-assert.md)
            * [Byzer mllib](/byzer-lang/en-us/extension/et/external/mlsql-mllib.md)
            * [shell command plugin](/byzer-lang/en-us/extension/et/external/mlsql-shell.md)
            * [Execute string as code](/byzer-lang/en-us/extension/et/external/run-script.md)
            * [Save to the incremental table and load again](/byzer-lang/en-us/extension/et/external/save-then-load.md)

- Development  
    * [Integration Test](/byzer-lang/en-us/developer/it/integration_test.md)     
    * API
      * [Byzer Engine Rest API](/byzer-lang/en-us/developer/api/README.md)
        * [Script Run API](/byzer-lang/en-us/developer/api/run_script_api.md)
        * [Byzer Meta Information Store](/byzer-lang/en-us/developer/api/meta_store.md)
      * [Liveness API](/byzer-lang/en-us/developer/api/liveness.md)
      * [Readness API](/byzer-lang/en-us/developer/api/readiness.md)
    * [Performance Tunning](/byzer-lang/en-us/developer/tunning/dynamic_resource.md)

- [Terms](/byzer-lang/en-us/appendix/terms.md)  

- Appendix
    * [Blog](/byzer-lang/en-us/appendix/blog.md)   

