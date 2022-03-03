# Byzer-lang 文件系统插件介绍

|Version | Author | Date | Comment|
|---|---|---|---|
v1.0|Jiachuan Zhu ( jiachuan.zhu@byzer.org) | 2022-01-28 | First version |

Byzer-lang 支持多种文件类型，例如本地文件系统，HDFS，Amazon S3等。但在数据处理时，通常需要访问多个文件系统，这时 Byzer-lang 的文件系统插件就很有用了。
简单配置后，即可以访问各类文件系统。下面以  Azure Blob 和 Amazon S3 的读写为例介绍其使用方式。

开始体验之前，请参考 安装文档 部署 Byzer-lang；您也可以在 byzer.org 体验这个功能。

## Amazon S3

为了读写Amazon S3，请将 hadoop-aws jar 包部署至 $SPARK_HOME/jars 或 Byzer-lang 安装目录的 libs 子目录，并重启 Byzer-lang。以下是适配 Byzer-lang_3.0-2.2.1 的AWS jar
```shell
wget https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.11.375/aws-java-sdk-bundle-1.11.375.jar
wget https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.2.0/hadoop-aws-3.2.0.jar
```

然后使用 SAVE LOAD 语句读写 AWS S3。

```sql
set rawData='''
{"jack":1,"jack2":2}
{"jack":2,"jack2":3}
''';
load jsonStr.`rawData` as table1;

SAVE OVERWRITE table1 as FS.`s3a://zjc-test-ap-northeast-1/test.csv` where
`fs.s3a.endpoint`="s3.ap-northeast-3.amazonaws.com"
and `fs.s3a.access.key`="access_key"
and `fs.s3a.secret.key`="secret_key"
and `fs.s3a.impl`="org.apache.hadoop.fs.s3a.S3AFileSystem"
and `fs.s3a.buffer.dir`="/tmp/oss"
and implClass="parquet";

load FS.`s3a://zjc-test-ap-northeast-1/test.csv` where
`fs.s3a.endpoint`="s3.ap-northeast-3.amazonaws.com"
and `fs.s3a.access.key`="access_key"
and `fs.s3a.secret.key`="secret_key"
and `fs.s3a.impl`="org.apache.hadoop.fs.s3a.S3AFileSystem"
and `fs.s3a.buffer.dir`="/tmp/oss"
and implClass="parquet"
as table1;
```

上述语句声明了 S3 路径，AWS区域 ( fs.s3a.endpoint )，用户鉴权信息 (access key secret key) 和 文件格式。S3 路径格式为
`s3a://<bucket_name>/<name>`
文件格式支持 csv parquet 等。


## Azure Blob

使用前，请下载 `https://download.byzer.org/byzer/misc` 的 azure-blob Jar 至 `$SPARK_HOME/jars` 或 `Byzer-lang` 安装目录的 libs 子目录，并重启 Byzer-lang。
azure-blob_3.2-1.0-SNAPSHOT.jar 适配 byzer-lang_3.0-<versions>; azure-blob_2.7 适配 byzer-lang_2.4-<version.

与 S3 读写类似, 以下语句也声明了读写Azure Blob 必要参数
```sql
set rawData='''
{"jack":1,"jack2":2}
{"jack":2,"jack2":3}
''';
load jsonStr.`rawData` as table1;

SAVE overwrite table1 as FS.`wasb://<container>@<account>.blob.core.chinacloudapi.cn/tmp/json_names_1`
where `spark.hadoop.fs.azure.account.key.account.blob.core.chinacloudapi.cn`="<account_key>"
and `spark.hadoop.fs.AbstractFileSystem.wasb.impl`="org.apache.hadoop.fs.azure.Wasb"
and `spark.hadoop.fs.wasb.impl`="org.apache.hadoop.fs.azure.NativeAzureFileSystem"
and implClass="parquet";

load FS.`wasb://<container>@<account>.blob.core.chinacloudapi.cn/tmp/json_names`
where `spark.hadoop.fs.azure.account.key.<account>.blob.core.chinacloudapi.cn`="<account_key>"
and `spark.hadoop.fs.AbstractFileSystem.wasb.impl`="org.apache.hadoop.fs.azure.Wasb"
and `spark.hadoop.fs.wasb.impl`="org.apache.hadoop.fs.azure.NativeAzureFileSystem"
and implClass="parquet"
as table2;
```

下面表格说明了各个参数

| 参数                                                    | 含义                                     |
-------------------------------------------------------|----------------------------------------|
| container | 您创建的 Azure Blob container Container 名称 |
| account | 您的 Azure Blob 账号                       |
| account_key | 访问 Container 的密钥                       |
| spark.hadoop.* | 以 spark.hadoop 开头表示文件系统相关参数            | 
| implClass = "parquet" | 文件格式为 parquet                          |

## 文件系统插件的实现
熟悉了使用方式，我们了解下实现方式。文件系统插件的实现类为 `streaming.core.datasource.CustomFS`

save  和 load 分别实现数据读取和保存，依托 Spark DataSource API 强大的扩展能力，以简单优雅的方式支持各种文件存储。
