## 设置 Intellij IDE 开发环境

首先 clone 项目到本地：

```
git clone https://github.com/byzer-org/byzer-lang
```

项目有点大，需要有点耐心。 Byzer-lang 是属于 Maven项目，所以你的 Intellj Idea 需要安装如下插件：

1. Maven
2. Java
3. Scala

其中 Maven 推荐推荐 3.6.3 版本。

当从 IDE 以 Maven 方式导入项目后，随意打开一个 Scala文件，会询问你 Scala 的版本，这个时候请选择 2.12.15。

### 如何本地 Debug

找到类  `tech.mlsql.example.app.LocalSparkServiceApp`, 在IDE 中点击 Debug运行，然后你就可以访问 http://localhost:9003/ 了。

此外，比如我个人为了方便，也会在 子模块 `streamingpro-mlsql` 中的 `/src/main/java` 随便一个package下新建一个 `WilliamLocalSparkServiceApp` ,然后复制黏贴如下代码，之后用 IDE debug模式启动该类即可。

```scala
package streaming.core

object WilliamLocalSparkServiceApp {
  def main(args: Array[String]): Unit = {
    StreamingApp.main(Array(
      "-streaming.master", "local[*]",
      "-streaming.name", "god",
      "-streaming.rest", "true",
      "-streaming.thrift", "false",
      "-streaming.platform", "spark",
      "-spark.mlsql.enable.runtime.directQuery.auth", "true",
      "-spark.mlsql.datalake.overwrite.hive", "false",
      "-streaming.enableHiveSupport", "false",
      "-spark.mlsql.path.schemas", "oss,s3a,s3,abfs,file",      
      "-streaming.spark.service", "true",
      "-streaming.job.cancel", "true",
      "-streaming.datalake.path", "/Users/allwefantasy/projects/byzer-lang/__mlsql__/data",    

      "-streaming.rest.intercept.clzz", "streaming.rest.ExampleRestInterceptor",
      "-spark.driver.maxResultSize", "2g",
      "-spark.serializer", "org.apache.spark.serializer.KryoSerializer",
      
      "-spark.kryoserializer.buffer.max", "2000m",
      "-spark.sql.adaptive.enabled", "true",
      "-streaming.driver.port", "9003"      
      
    ))
  }
}

```

`-streaming.datalake.path` 配置本地自己一个目录即可。