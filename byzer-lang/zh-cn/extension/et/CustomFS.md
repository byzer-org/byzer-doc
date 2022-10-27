# 文件系统插件

Byzer 文件系统插件提供了访问外部 HDFS 兼容的文件系统的能力。

## 基本语法

文件系统插件需要配合 `SAVE / LOAD` 语句，语法如下所示:
```sql
SAVE [OVERWRITE|APPEND] <table_name> AS FS.`<scheme>://<path>`
WHERE `<config_name>` = "<config_value>"
AND `implClass`=<format>;

LOAD FS.`<scheme>://<path>`
WHERE `<config_name>` = "<config_value>"
AND `implClass`=<format>
AS <table_name>;
```

|名称| 解释                           |
|---|------------------------------|
| table_name| Byzer 虚拟表名                   |
| scheme | 文件系统类型。例如 s3a oss            |
| path| 读写的目录                        |
|config_name| 文件系统读写的参数                    |
| implClass| 文件格式 可以是 parquet csv text 等 |



## S3

### 部署 S3 插件

S3 插件本质是 hadoop-s3 jar，Byzer 社区解决了版本适配问题，并提供了更高效的部署流程。
请参考 [Byzer S3 插件](https://github.com/byzer-org/byzer-extension/tree/master/byzer-objectstore-s3)  部署插件，该版本适配 Spark 3.3.0 Hadoop 3.x
更低的版本，请[下载适配的插件 jar](https://download.byzer.org/byzer/misc/cloud/s3/) ，并部署至 Byzer-lang 安装目录的 libs 子目录。
若您的 Byzer-lang 版本低于 2.2.2 ，请手动添加 jar 包至 classpath，如下所示。2.2.2 或更高版本无需手动添加，请执行 `bin/byzer.sh` 命令启动。
```
--conf spark.driver.extraClassPath=/<path>/byzer-lang/libs/<s3-jar-name>
--conf spark.executor.extraClassPath=/<path>/byzer-lang/libs/<s3-jar-name>
```

S3 插件和 Spark Hadoop 版本兼容性如下:

|S3 插件名|兼容Spark Hadoop版本|
|---|---|
|byzer-objectstore-s3-3.3_2.12-0.1.0-SNAPSHOT.jar| Spark 3.3.0, Hadoop 3.x|
|aws-s3_3.3.1-1.0.1-SNAPSHOT.jar | 低于 3.3.0的 Spark, hadoop 3.3.x|
|aws-s3_3.2.0-1.0.0-SNAPSHOT.jar | 低于 3.3.0的 Spark, hadoop 3.2.x|


### 写 S3 

假设保存数据至 S3 bucket `test-bucket`，test 目录，保存为 parquet 格式。有下面例子，`where` 参数缺一不可。

```sql
SELECT 1 AS table1;

SAVE OVERWRITE table1 as FS.`s3a://test-bucket/test` 
where `fs.s3a.endpoint`="s3.cn-northwest-1.amazonaws.com.cn"
and `fs.s3a.access.key`="access_key"
and `fs.s3a.secret.key`="secret_key"
and `fs.s3a.impl`="org.apache.hadoop.fs.s3a.S3AFileSystem"
and `implClass`="parquet";

```

| 参数                | 解释                                                                                                                                                                                                             |
|-------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| s3a://test-bucket/test | test-bucket 为 S3 bucket 名称；test 为目录                                                                                                                                                                            |
| fs.s3a.endpoint   | 根据S3 Bucket 所在区域填写。AWS CN 请参考 [CN S3](https://docs.amazonaws.cn/aws/latest/userguide/endpoints-arns.html), AWS Global 请参考[Global](https://docs.aws.amazon.com/general/latest/gr/rande.html#regional-endpoints) |
| fs.s3a.access.key | 访问 S3 使用的 access key，相当于用户名                                                                                                                                                                                    |
| fs.s3a.secret.key | 访问 S3 使用的 secret key，相当于密码                                                                                                                                                                                     |                                                                                                                                                                                   
| fs.s3a.impl       | S3 文件系统的实现类                                                                                                                                                                                                    |
| implClass | 文件格式，可以是 parquet csv text orc                                                                                                                                                                                  |          

使用时，若碰到 403 问题。您可以在 Byzer-lang 服务器[安装 aws CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html), 执行 `aws configure` 设置 access key, secret key
区域(region)，再执行 `aws s3 cp` 命令上传或下载文件至 S3 bucket. 若成功，表示 access key secret key 有足够权限。Byzer 文件系统插件的设置的 access key secret 有误。
这类情况常见于**多 bucket 读写**，Byzer S3 插件在成功读写 S3 后，会缓存 access key secret key，并用于访问另一 bucket ，因而报错。建议使用以下参数：

| 参数                | 解释                                                                                                                                                                                                             |
|-------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| fs.s3a.bucket.<bucket-name>.access.key | 访问 S3 bucket 使用的 access key，相当于用户名                                                                                                                                                                                    |
| fs.s3a.bucket.<bucket-name>.secret.key | 访问 S3 bucket 使用的 secret key，相当于密码                                                                                                                                                                                     |
| fs.s3a.aws.credentials.provider | org.apache.hadoop.fs.s3a.SimpleAWSCredentialsProvider，不使用缓存的 access key secret key |

例子如下：

```sql
SELECT 1 AS table1;

SAVE OVERWRITE table1 as FS.`s3a://test-bucket/test` 
where `fs.s3a.endpoint`="s3.cn-northwest-1.amazonaws.com.cn"
and `fs.s3a.bucket.test-bucket.access.key`="access_key"
and `fs.s3a.bucket.test-bucket.secret.key`="secret_key"
and `fs.s3a.impl`="org.apache.hadoop.fs.s3a.S3AFileSystem"
and `fs.s3a.aws.credentials.provider`="org.apache.hadoop.fs.s3a.SimpleAWSCredentialsProvider"
and `implClass`="parquet";

```

### 读 S3
和写 S3 非常类似，依然使用上述参数。给出一个例子

```sql
LOAD FS.`s3a://test-bucket/test`
where `fs.s3a.endpoint`="s3.cn-northwest-1.amazonaws.com.cn"
and `fs.s3a.bucket.test-bucket.access.key`="access_key"
and `fs.s3a.bucket.test-bucket.secret.key`="secret_key"
and `fs.s3a.impl`="org.apache.hadoop.fs.s3a.S3AFileSystem"
and `fs.s3a.aws.credentials.provider`="org.apache.hadoop.fs.s3a.SimpleAWSCredentialsProvider"
and `implClass`="parquet"
AS test;
```

### CSV 文件格式参数
不同于 parquet，csv 文件可以指定更低参数。请参考[CSV 相关参数](https://docs.byzer.org/#/byzer-lang/zh-cn/datasource/file/file?id=csv)
