# 华为云 OBS

在线安装驱动：

```
!plugin app add - "byzer-objectstore-obs-3.3";
```

离线安装驱动：

请到 Byzer 下载站 https://download.byzer.org/byzer/misc/cloud/ 下载对应的驱动，然后将其置于 ${SPARK_HOME}/jars 或者 ${Byzer_HOME}/libs 目录中。然后常规哦暖气。

你可以使用如下方式注册对象存储文件系统：

```sql

load FS.``
Where `fs.obs.endpoint`="obs.ap-southeast-3.myhuaweicloud.com"
and `fs.obs.impl`="org.apache.hadoop.fs.obs.OBSFileSystem"
and `fs.AbstractFileSystem.obs.impl`="org.apache.hadoop.fs.obs.OBSorg.apache.hadoop.fs.obs.OBS"
and `fs.obs.access.key`="xxxx"
and `fs.obs.secret.key`="xxxx"
as output;

```

然后你就可以使用如下语句访问该对象存储了：

```sql
load parquet.`obs://xxxxx/poc/city_temperatures`  as city_temperatures;
```