# 开发 Byzer-SQL 内置UDF

我们可以在 Byzer-SQL 脚本中直接通过 register UDF 来注册自定义的 UDF 函数，但这个功能还不够强大，如果用户希望开发非常复杂的UDF，那么可以用 Scala 来开发内置UDF。

总体而言，要开发一个内置的UDF,需要做如下步骤：

1. 创建一个scala项目
2. 通过mvn install 安装 byzer-lang 依赖
3. 开发UDF函数
4. 打出一个jar包
5. 将jar包放到 BYZER_HOME/plugin 目录下
6. 在配置文件（conf/byzer.properties.override）中添加一个配置： `streaming.udf.clzznames`

下面是一个具体的流程：

## 创建一个scala项目

用 maven创建一个scala项目。 scala版本和 byzer-lang保持一致。 2.12.15。

## 通过mvn install 安装 byzer-lang 依赖

在你的开发环境中，git clone byzer-lang 主项目，然后进行一次install:

```bash
mvn clean install -DskipTests -Ponline  -pl streamingpro-mlsql -am
```

这样你就可以在上面的项目中引入 byzer-lang 相关的依赖了。

```xml
<properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>

        <scala.version>2.12.15</scala.version>
        <scala.binary.version>2.12</scala.binary.version>
        <spark.version>3.3.0</spark.version>
        <spark.bigversion>3.3</spark.bigversion>
        <spark.binary.version>3.3</spark.binary.version>
        <scalatest.version>3.2.13</scalatest.version>
        <mlsql.version>2.4.0-SNAPSHOT</mlsql.version>
        <delta-plus.version>0.4.0</delta-plus.version>
        <guava.version>16.0</guava.version>
        <httpclient.version>4.5.3</httpclient.version>
        <common-utils-version>0.3.9.5</common-utils-version>
        <serviceframework.version>2.0.9</serviceframework.version>
        <scope>provided</scope>
        <hadoop-client-version>2.6.5</hadoop-client-version>
        <bigdl.version>0.8.0</bigdl.version>
    </properties>
<dependencies>
<dependency>
    <groupId>tech.mlsql</groupId>
    <artifactId>common-utils_${scala.binary.version}</artifactId>
    <version>${common-utils-version}</version>
    <scope>${scope}</scope>
    </dependency>

    <dependency>
    <groupId>tech.mlsql</groupId>
    <artifactId>streamingpro-mlsql-spark_${spark.bigversion}_${scala.binary.version}</artifactId>
    <version>${mlsql.version}</version>
    <scope>${scope}</scope>
    </dependency>

    <dependency>
    <groupId>tech.mlsql</groupId>
    <artifactId>streamingpro-core-${spark.bigversion}_${scala.binary.version}</artifactId>
    <version>${mlsql.version}</version>
    <scope>${scope}</scope>
    </dependency>

    <dependency>
    <groupId>tech.mlsql</groupId>
    <artifactId>streamingpro-common-${spark.bigversion}_${scala.binary.version}</artifactId>
    <version>${mlsql.version}</version>
    <scope>${scope}</scope>
    </dependency>

    <dependency>
    <groupId>tech.mlsql</groupId>
    <artifactId>streamingpro-spark-${spark.version}-adaptor_${scala.binary.version}</artifactId>
    <version>${mlsql.version}</version>
    <scope>${scope}</scope>
    </dependency>
</dependencies>    
```

## 开发UDF函数

```scala
package tech.mlsql.crawler.udf

import cn.edu.hfut.dmic.contentextractor.ContentExtractor
import org.apache.spark.sql.UDFRegistration
import org.jsoup.Jsoup
import tech.mlsql.crawler.{HttpClientCrawler, RestUtils}
import us.codecraft.xsoup.Xsoup

/**
 * Created by allwefantasy on 3/4/2018.
 */
object Functions {
  def crawler_auto_extract_body(uDFRegistration: UDFRegistration) = {
    uDFRegistration.register("crawler_auto_extract_body", (co: String) => {
      if (co == null) null
      else ContentExtractor.getContentByHtml(co)
    })
  }

  def crawler_auto_extract_title(uDFRegistration: UDFRegistration) = {
    uDFRegistration.register("crawler_auto_extract_title", (co: String) => {
      if (co == null) null
      else {
        val doc = Jsoup.parse(co)
        doc.title()
      }

    })
  }

  def crawler_request(uDFRegistration: UDFRegistration) = {
    uDFRegistration.register("crawler_request", (co: String) => {
      val docStr = HttpClientCrawler.request(co)
      if (docStr != null) {
        val doc = Jsoup.parse(docStr.pageSource)
        if (doc == null) null
        else
          doc.html()
      } else null
    })
  }


  def crawler_request_image(uDFRegistration: UDFRegistration) = {
    uDFRegistration.register("crawler_request_image", (co: String) => {
      val image = HttpClientCrawler.requestImage(co)
      image
    })
  }


  def crawler_http(uDFRegistration: UDFRegistration) = {
    uDFRegistration.register("crawler_http", (url: String, method: String, items: Map[String, String]) => {
      HttpClientCrawler.requestByMethod(url, method, items)
    })
  }

  def rest_request_string(uDFRegistration: UDFRegistration) = {
    uDFRegistration.register("rest_request", (url: String, method: String, params: Map[String, String],
                                              headers: Map[String, String], config: Map[String, String]) => {
      val (_, content) = RestUtils.rest_request_string(url, method, params, headers, config)
      content
    })
  }

  def rest_request(uDFRegistration: UDFRegistration) = {
    uDFRegistration.register("rest_request", (url: String, method: String, params: Map[String, String],
                                              headers: Map[String, String], config: Map[String, String]) => {
      val (_, content) = RestUtils.rest_request_binary(url, method, params, headers, config)
      content
    })
  }

  def crawler_extract_xpath(uDFRegistration: UDFRegistration) = {
    uDFRegistration.register("crawler_extract_xpath", (html: String, xpath: String) => {
      if (html == null) null
      else {
        val doc = Jsoup.parse(html)
        doc.title()
        Xsoup.compile(xpath).evaluate(doc).get()
      }

    })
  }

  def crawler_md5(uDFRegistration: UDFRegistration) = {
    uDFRegistration.register("crawler_md5", (html: String) => {
      if (html == null) null
      else {
        java.security.MessageDigest.getInstance("MD5").digest(html.getBytes()).map(0xFF & _).map {
          "%02x".format(_)
        }.foldLeft("") {
          _ + _
        }
      }

    })
  }

}
```

定义一个 Object 类，名字随意。

在这个 Object 类中，我们定义了一系列的UDF函数，比如 crawler_auto_extract_body，crawler_auto_extract_title等等。

以 `crawler_request` 为例：

```scala
def crawler_request(uDFRegistration: UDFRegistration) = {
    uDFRegistration.register("crawler_request", (co: String) => {
        val docStr = HttpClientCrawler.request(co)
        if (docStr != null) {
        val doc = Jsoup.parse(docStr.pageSource)
        if (doc == null) null
        else
            doc.html()
        } else null
    })
}
```

register("crawler_request", 中的 `crawler_request` 是在 Byzer-SQL 中调用的函数名，后面的 `(co: String) => {` 是函数的实现。

你可以把上面的代码，打包成一个jar包。

## 如何打包

将你的项目打包，然后把将jar包放到 BYZER_HOME/plugin 目录下。

## 注册

接着，在配置文件（conf/byzer.properties.override）中添加一个配置： `streaming.udf.clzznames` 
在这个配置中指定完整的类名，比如：

```properties
streaming.udf.clzznames=tech.mlsql.crawler.udf.Functions
```

如果有多个类，可以用逗号分隔。

最后通过 `./bin/byzer.sh restart` 重启生效。