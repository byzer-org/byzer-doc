# byzer 断言

[byzer 断言](https://github.com/byzer-org/byzer-extension/tree/master/mlsql-assert) 插件提供了在表中使用 `assert` 断言命令，用于判断 byzer 的结果表中数据是否符合预期。


## 如何安装

Execute following command in web console:

```
!plugin app add - "mlsql-assert-3.0";
```

> 注意：示例中 byzer 的 spark 版本为 3.0 ，如果需要在 spark 2.4 的版本运行，请将安装的插件设置为 `mlsql-assert-2.4`

## 如何使用

```sql
-- 创建测试数据
set jsonStr='''
{"features":[5.1,3.5,1.4,0.2],"label":0.0},
{"features":[5.1,3.5,1.4,0.2],"label":1.0}
{"features":[5.1,3.5,1.4,0.2],"label":0.0}
{"features":[4.4,2.9,1.4,0.2],"label":0.0}
{"features":[5.1,3.5,1.4,0.2],"label":1.0}
{"features":[5.1,3.5,1.4,0.2],"label":0.0}
{"features":[5.1,3.5,1.4,0.2],"label":0.0}
{"features":[4.7,3.2,1.3,0.2],"label":1.0}
{"features":[5.1,3.5,1.4,0.2],"label":0.0}
{"features":[5.1,3.5,1.4,0.2],"label":0.0}
''';
load jsonStr.`jsonStr` as data;
select vec_dense(features) as features ,label as label from data
as data1;

-- 使用 RandomForest
train data1 as RandomForest.`/tmp/model` where

-- 一旦设置为 true，每次运行此脚本时，byzer 都会为您的模型生成新目录
keepVersion="true"

-- 指定测试数据集，该数据集将用于提供评估器以生成一些指标，例如：F1, Accurate
and evaluateTable="data1"

-- 设置 group 0 参数
and `fitParam.0.labelCol`="features"
and `fitParam.0.featuresCol`="label"
and `fitParam.0.maxDepth`="2"

-- 设置 group 1 参数
and `fitParam.1.featuresCol`="features"
and `fitParam.1.labelCol`="label"
and `fitParam.1.maxDepth`="10"
as model_result;

select name,value from model_result where name="status" as result;

-- 确保所有模型的状态都是成功的
!assert result ''':value=="success"'''  "all model status should be success";
```
如果最终执行结果的 value 不是 "success"，则会在 Console 显示异常信息如下：

```
all model status should be success
java.lang.RuntimeException: all model status should be success
tech.mlsql.plugins.assert.ets.Assert.train(Assert.scala:93)
tech.mlsql.dsl.adaptor.TrainAdaptor.parse(TrainAdaptor.scala:102)
streaming.dsl.ScriptSQLExecListener.execute$1(ScriptSQLExec.scala:368)
streaming.dsl.ScriptSQLExecListener.exitSql(ScriptSQLExec.scala:407)
streaming.dsl.parser.DSLSQLParser$SqlContext.exitRule(DSLSQLParser.java:296)
org.antlr.v4.runtime.tree.ParseTreeWalker.exitRule(ParseTreeWalker.java:47)
org.antlr.v4.runtime.tree.ParseTreeWalker.walk(ParseTreeWalker.java:30)
org.antlr.v4.runtime.tree.ParseTreeWalker.walk(ParseTreeWalker.java:28)
streaming.dsl.ScriptSQLExec$._parse(ScriptSQLExec.scala:159)
streaming.dsl.ScriptSQLExec$.parse(ScriptSQLExec.scala:146)
streaming.rest.RestController.$anonfun$script$1(RestController.scala:136)
tech.mlsql.job.JobManager$.run(JobManager.scala:74)
tech.mlsql.job.JobManager$$anon$1.run(JobManager.scala:91)
java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1149)
java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
java.lang.Thread.run(Thread.java:748)
```









