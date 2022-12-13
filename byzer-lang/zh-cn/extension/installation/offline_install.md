# 离线安装插件

> 2.0.1-SNAPSHOT、2.0.1 及以上版本支持。

考虑到很多场景，我们需要引擎启动的时候就具备某个插件的功能，亦或是我们没办法访问外部网络，这个时候就可以通过离线方式安装插件。

## 下载Jar包并且上传到你的服务器

```
wget http://store.mlsql.tech/run?action=downloadPlugin&pluginType=MLSQL_PLUGIN&pluginName=byzer-objectstore-oss-3.3&version=0.1.0-SNAPSHOT
```

值得注意的是，在上面的参数中，唯一需要根据场景修改的是 `pluginName`和 `version` . 
可以关注我们的插件项目： [Byzer Extension](https://github.com/byzer-org/byzer-extension)

下载的插件包，放到我们发行版的 plugin 目录即可。

## 启动时配置jar包以及启动类

除了对象存储类的插件，为了能够让插件生效，我们需要在启动脚本里，
配置插件主类(这里以Excel插件安装为例)：

```
-streaming.plugin.clzznames tech.mlsql.plugins.ds.MLSQLExcelApp
```

如果你直接使用 spark-submit 进行提交，你需要使用 `--jar` 将我们上一个步骤的jar包带上：

```
--jar <your file path>/mlsql-excel-2.4_2.11.jar
```

> 注意，jar应该放到程序执行目录下，否则jvm启动会找不到该类