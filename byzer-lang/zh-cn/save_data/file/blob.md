# Azure Blob/abfs


在线安装驱动：

```
!plugin app add - "byzer-objectstore-blob-3.3";
```

离线安装驱动：

请到 Byzer 下载站 https://download.byzer.org/byzer/misc/cloud/ 下载对应的驱动，然后将其置于 ${SPARK_HOME}/jars 或者 ${Byzer_HOME}/libs 目录中。然后常规哦暖气。

你可以使用如下方式注册对象存储文件系统：

```sql
LOAD FS.``
WHERE `fs.abfs.impl`="org.apache.hadoop.fs.azurebfs.AzureBlobFileSystem"
AND `fs.azure.account.auth.type.xxxx.dfs.core.windows.net`="SharedKey"
AND `fs.azure.account.key.xxxxx.dfs.core.windows.net`="${azure_key}"
AS output;

-- 或者可能你用的是 wasb，可以这么注册

LOAD FS.``
WHERE `fs.AbstractFileSystem.wasb.impl`="org.apache.hadoop.fs.azure.Wasb"
AND `fs.wasb.impl`="org.apache.hadoop.fs.azure.NativeAzureFileSystem"
AND `fs.azure.account.key.flagk8sstorage.blob.core.chinacloudapi.cn`="${azure_key}"
AS output;
```

然后你就可以使用如下语句访问该对象存储了：

```sql
-- wasb://<storage_account>@<container_name>.blob.core.chinacloudapi.cn/
load parquet.`abfs://xxx@xxxx.dfs.core.windows.net/poc/region_country_city` 
as region_country_city;
```