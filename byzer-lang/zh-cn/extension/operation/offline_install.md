# 离线安装插件

> 2.0.1-SNAPSHOT、2.0.1 及以上版本支持。

考虑到很多场景，我们需要引擎启动的时候就具备某个插件的功能，亦或是我们没办法访问外部网络，这个时候就可以通过离线方式安装插件。

## 下载Jar包并且上传到你的服务器

```bash
wget http://store.mlsql.tech/run?action=downloadPlugin&pluginType=MLSQL_PLUGIN&pluginName=byzer-objectstore-oss-3.3&version=0.1.0-SNAPSHOT
```

值得注意的是，在上面的参数中，唯一需要根据场景修改的是 `pluginName`和 `version` . 
可以关注我们的插件项目： [Byzer Extension](https://github.com/byzer-org/byzer-extension)

下载的插件包，放到我们发行版的 plugin 目录即可。

## 启动时配置jar包以及启动类

除了对象存储类的插件，为了能够让插件生效，我们需要在启动脚本里，
配置插件主类(这里以Excel插件安装为例)：

```properties
-streaming.plugin.clzznames tech.mlsql.plugins.ds.MLSQLExcelApp
```

如果你直接使用 spark-submit 进行提交，你需要使用 `--jar` 将我们上一个步骤的jar包带上：

```
--jar <your file path>/mlsql-excel-2.4_2.11.jar
```

> 注意，jar应该放到程序执行目录下，否则jvm启动会找不到该类

## 如何查找插件信息

官方提供的插件主要都在 https://github.com/byzer-org/byzer-extension 项目中。根据前面的描述，你需要准备插件jar包和配置插件入口类，你可以
通过在该项目里的插件子目录找到相关信息。

比如假设你安装 byzer-openmldb, 那么可以打开 https://github.com/byzer-org/byzer-extension/blob/master/byzer-openmldb/desc.plugin ，可以看到 mainClass 信息，以及插件 moduleName 等信息。

## 如何自己编译插件

如果你需要自己编译插件，需要先安装byzer-lang 依赖，然后再编译插件。具体做法如下：

```bash
git clone https://github.com/byzer-org/byzer-lang
cd byzer-lang
mvn clean install -DskipTests -Ponline -pl streamingpro-mlsql -am 
```

编译成功之后，就可以编译插件了：

```bash
mvn clean install -Pshade -DskipTests -pl ${MODULE}
```

其中 `${MODULE}` 是插件的模块名，比如 byzer-openmldb



