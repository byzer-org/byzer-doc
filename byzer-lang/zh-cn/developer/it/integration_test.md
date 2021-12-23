# 集成测试框架设计

### 目标

1. 给定一组 Byzer-lang 脚本，测试其行为的正确性
2. 能够轻易的添加 TestCase
3. 能够指定测试所需的数据

### 实体设计

#### LocalBaseTestSuite

BeforeAll
1. 设置 Working Directory
2. 设置启动参数和环境参数 （允许子类修改）
3. 拷贝测试数据至用户目录
4. 加载测试用例
5. 创建 Platform Manager
6. 创建 Spark Runtime
7. 加载 mlsql assert 插件

AfterAll
1. 清理 Platform
2. 清理 Spark Runtime
3. 清理运行临时文件

RunTestCase
1. 按目录按文件名排序依次执行 mlsql 脚本
2. 对比每个 mslql 脚本的预期输出结果
3. 记录运行结果

> 同一个 TestSuite 中的测试用例可能存在前后引用

#### Comparator

以下为脚本预期可能的情况:

1. 脚本输出表格形式，需要对比每个 cell 的值，支持正则匹配

```
测试用例：01_hdfs_command_test.mlsql
测试语句：!hdfs -ls /tmp;
测试结果文件内容：
fileSystem
Found 1 items[\\s\\S]+
```
> 预期结果文件的命名格式为 ${testcase}.mlsql.expected

2. 脚本输出不固定，不对比结果，只要没有异常即可

```
测试用例：07_show_version_test.mlsql
测试语句：
--%comparator=tech.mlsql.it.IgnoreResultComparator
!show version;
预期结果：从 hint 中选用不对比结果的 Comparator
```

> --% comparator 可以自定义 Comparator，需要是 tech.mlsql.it.Comparator 的子类

3. 脚本运行报错，符合给定的预期异常和报错信息

```
测试用例：05_mlsql_assert_test.mlsql
测试语句：
--%exception=java.lang.RuntimeException
--%msg=all model status should be success

-- !plugin app remove "mlsql-assert-2.4";
-- !plugin app add - "mlsql-assert-2.4";
-- create test data
set jsonStr='''
{"features":[5.1,3.5,1.4,0.2],"label":0.0},
...
...
select name,value from model_result where name="status" as result;
-- make sure status of  all models are success.
!assert result ''':value=="success"'''  "all model status should be success";
预期结果：从 hint 得知异常和错误信息

```
> --%exception 指定预期错误异常
--%msg 指定预期错误信息，支持正则表达式

以下为脚本运行结果不符合预期的情况:

1. 运行报错，但未设置预期报错

```text
报错信息为：
========== Error TestCase ============
Error: xxx testcase failed, error msg is
java.lang.xxxException: root cause
    stacktrace....

```

2. 运行报错，且与预期报错不一致

```text
报错信息为：
========== Error TestCase ============
Error: xxx testcase failed, error msg is
Expected exception and message: xxx
Actual exception and message: xxx
```

3. 运行正常，但结果不一致

```text
报错信息为：
========== Error TestCase ============
Error: xxx testcase failed, error msg is
Expected Result is:
xxxx
Actual Result is:
xxxx
```

### 如何进行测试

**在 IDEA 中测试**

点击 `Run -- Edit Configurations`, 点击`+`, 选择 ScalaTest 类型，设置 类为 `tech.mlsql.it.SimpleQueryTestSuite` `Working directory` 为 `streamingpro-it`

`打开 SimpleQueryTestSuite -> 右键 Run`

**在 Maven 中测试**

```shell
mvn clean install -DskipTests
mvn test -pl streamingpro-it
```