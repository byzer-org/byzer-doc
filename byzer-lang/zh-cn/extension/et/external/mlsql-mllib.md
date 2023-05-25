# Byzer mllib

[byzer mllib](https://github.com/byzer-org/byzer-extension/tree/master/mlsql-mllib) 插件将 spark-mllib 包装为 byzer ET 使用。

### 如何安装

1. 在 Web 控制台中执行以下命令：

```
!plugin app add "tech.mlsql.plugins.mllib.app.MLSQLMllib" "mlsql-mllib-3.0";
```

> 注意：示例中 byzer 的 spark 版本为 3.0 ，如果需要在 spark 2.4 的版本运行，请将安装的插件设置为 `mlsql-mllib-2.4`

检查是否安装成功，可以执行如下宏命令，用于查看ET组件的信息：

```
!show et/ClassificationEvaluator;
!show et/RegressionEvaluator;
```

2. 手动安装

您也可以手动安装，首先，在你的终端中构建 shade jar：

```shell
pip install mlsql_plugin_tool
mlsql_plugin_tool build --module_name mlsql-mllib --spark spark243
```

然后更改 byzer 引擎的启动脚本，添加jar包：

```
--jars YOUR_JAR_PATH
```

在byzer中注册类:

```
-streaming.plugin.clzznames tech.mlsql.plugins.mllib.app.MLSQLMllib
```

如果有多个类，请使用逗号分隔它们。 例如:

```
-streaming.plugin.clzznames classA,classB,classC
```

### 如何使用

Classification:

```sql
predict data as RandomForest.`<your model HDFS path>` as predicted_table;
run predicted_table as ClassificationEvaluator.``;
```

Regression:

```sql
predict data as LinearRegressionExt.`<your model HDFS path>` as predicted_table;
run predicted_table as RegressionEvaluator.``;
```

更多 mllib 插件：

- [唯一标识符算子](/byzer-lang/zh-cn/ml/eda/UniqueIdentifier.md)
- [频数分布算子](/byzer-lang/zh-cn/ml/eda/DescriptiveMetrics.md)
