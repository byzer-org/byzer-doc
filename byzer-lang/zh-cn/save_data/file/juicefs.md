# JuiceFS 

> JuiceFS 为内置支持，无需安装

你可以使用如下方式注册该文件系统：

```sql

load FS.``
Where `fs.jfs.impl`="io.juicefs.JuiceFileSystem"
and `fs.AbstractFileSystem.jfs.impl`="io.juicefs.JuiceFS"
and `juicefs.name`="xxxx"
and `juicefs.meta`="meta: mysql://xxxx:xxxx@(xxxxx:3306)/juicefs"
and `juicefs.cache-dir`="/tmp/jfs"
as output;

```

然后你就可以使用如下语句访问该对象存储了：

```sql
load parquet.`jfs://xxxxx/poc/city_temperatures`  as city_temperatures;
```