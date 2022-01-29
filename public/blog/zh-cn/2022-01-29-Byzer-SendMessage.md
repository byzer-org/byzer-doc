# 利用 Byzer-lang 通过 nginx 日志统计网站 PV



| Version | Author          | Date       | Comment          |
| ------- | --------------- | ---------- | ---------------- |
| V 1.0   | @Lin Zhang 张琳 | 2021/11/11 |                  |
| V 2.0   | @Lin Zhang 张琳 | 2022/1/9   | 更新为最新的文章 |



## 背景

Byzer-lang 是一个面向大数据和AI的分布式可扩展语言，具备数据管理，商业分析，机器学习等能力。使用Byzer-lang 几句简单代码就可以让您快速验证和开发功能需求，Byzer-lang 内置了大量的插件可以帮我们完成很多有价值的工作。用户也可以可通过插件商店获取更多能力亦或是自定义插件轻松实现个性化的场景拓展。



今天我们主要来介绍下 Byzer-lang 中使用会非常高频的邮件插件，同时介绍下载对 Nginx 日志做PV统计时，我们如何将统计结果通过邮件发送给指定的用户。



> Byzer-lang项目地址 : https://github.com/byzer-org/byzer-lang



## Why Byzer-lang ？

传统分析型的报表系统，流程非常长，需要较多人工维护成本和开发迭代的成本。一般会有一个邮件服务，该服务会定制开发一套 DSL语法，用于在交互层面方便用户在邮件模板中使用，如：查询 SQL、调度周期语法糖、自定义参数、公共参数等。然后会有一个调度框架周期性触发邮件任务计算。下面笔者举一个具体的业务流程。



- 用户通过邮件服务系统使用 DSL 配置好一个邮件任务，并设置输入源等配置信息。输入源一般来自数据仓库 DM 层（数据集市层）或者 DWS（分析层）



- 日志通过分布式日志上报服务上传日志数据到hdfs



- 通过分布式计算引擎（spark, flink 等）读取日志做清洗和计算工作，产出一张分析层使用的表



- 当调度框架（Fuxi, Azkaban 等）满足调度周期或者调度依赖关系后，触发邮件任务



- 邮件服务接收到邮件任务后，根据邮件模板配置的调度周期等信息仿真为 Hive SQL，查询该分析层的表数据并进行计算，生成邮件内容发送邮件



- 对应的邮件服务器收到邮件，推送到用户手机



![img](../zh-cn/images/sendMessage.assets/(null)-20220129183514495.(null).jpeg)

我们发现上述流程已经非常复杂，有没有快速简洁的方式，无需多方合作，无需定制化开发，就能完成一个企业级可复用的邮件工具呢？这时 Byzer-lang 的优势便体现出来了。只需几行代码，就能完成上述复杂的流程。



现在我们看看使用 Byzer-lang 如何高效简洁的完成上面任务。首先我们先来看 Byzer-lang 是如何发送邮件的，其次我们会举一个 Nginx 日志分析的场景。



## What is SendMessage ET ？

[SendMessage](http://mlsql-docs.kyligence.io/latest/zh-hans/process/estimator_transformer/SendMessage.html) 是我们常用的发送消息的 ET，目前支持邮件的方式。除此之外，我们还有一个单独的 ET（FeishuMessageExt）支持飞书消息，后续也会支持更多的 SNS 工具的消息交互。本节内我们先了解下邮件ET的使用方式。



### **1、配置参数**

> 红色字体参数为必填项。

参数名参数含义method消息发送方式，目前支持：MAIL（邮件发送）；默认值为MAILmailType邮件服务类型，目前支持：local（使用本地sendmail服务）、config（sql配置SMTP服务器）；默认值为localuserName邮箱服务用户名，即邮箱账号，如：[do_not_reply@gmail.com](http://do_not_reply@gmail.com)；如果为config模式该值必填。password邮箱服务授权码；如果为config模式该值必填。from发件人邮箱账户to收件人邮箱账户，多个账户使用','分隔cc抄送人邮箱账户，多个账户使用','分隔subject邮件标题content邮件内容contentType邮件内容的格式，目前支持标准的 Java Mail Content-Type，如：text/plain、text/html、text/csv、image/jpeg、application/octet-stream、multipart/mixedattachmentContentType邮件附件内容的格式，目前支持标准的 Java Mail Content-TypeattachmentPaths邮件附件地址，多个地址使用','分隔smtpHostSMTP邮件服务域名；如果为config模式该值必填。smtpPortSMTP邮件服务端口号；如果为config模式该值必填。properties.[邮件客户端配置]javaMail邮件客户端配置，常用配置如：properties.mail.debug、properties.mail.smtp.ssl.enable、properties.mail.smtp.ssl.enable、properties.mail.smtp.starttls.enable等

发送邮件支持2种方式，分别如下：



- local: 连接本地 sendmail 服务器的方式。需要用户在本地服务器部署 sendmail 服务，并配置好用户名、授权码等信息，在MLSQL中会连接本地服务发送邮件。通过 sendmail 服务我们可以灵活的选择 MDA（邮件投递代理）或者 MTA（邮件服务器）来处理邮件。



- config: 配置 SMTP 服务器的方式。在 MLSQL 中配置邮箱用户名和邮箱授权码、邮箱 SMTP 服务器地址、端口，通过授权码登录第三方客户端邮箱。如果使用个人或者企业邮箱推荐使用该方式。



### **2、如何使用**

下面看一个 config 方式的代码示例：

```SQL
set EMAIL_TITLE = "这是邮件标题";

set EMAIL_BODY = "MLSQL 任务 xx 运行完成，请及时查询结果";

set EMAIL_TO = "userAccountNumber@qq.com, userAccountNumber@163.com";



-- 使用配置账号的方式

run command as SendMessage.``

where method = "mail"

and from = "userAccountNumber@qq.com"

and to = "${EMAIL_TO}"

and subject = "${EMAIL_TITLE}"

and content = "${EMAIL_BODY}"

and smtpHost = "smtp.qq.com"

and smtpPort = "587"

-- 设置邮件客户端的协议为TLS协议，SSL协议的配置：

-- `properties.mail.smtp.ssl.enable`= "true"，默认为SSL协议

and `properties.mail.smtp.starttls.enable`= "true"

and userName = "userAccountNumber@qq.com"

and password="***"

;
```

> 其中，userAccountNumber 代表用户邮箱账号。



### 3、如何获取邮箱授权码（password）

不同邮箱获取授权码的方式不同，我们以`QQ邮箱`为例，首先访问 `设置 - 账户 - POP3/IMAP/SMTP/Exchange/CardDAV/CalDAV服务`，然后找到下图所示的菜单，开启 POP3/SMTP 服务，并点击`生成授权码`。

![img](../zh-cn/images/sendMessage.assets/(null)-20220129183514618.(null).jpeg)

**想了解更多详细的使用说明，参考 Byzer-lang 官网文档：****[如何发送邮件](http://mlsql-docs.kyligence.io/latest/zh-hans/process/estimator_transformer/SendMessage.html)**



了解完具体的使用方式，我们来看下怎么使用邮件插件来处理具体的业务问题吧。



### 4、Example

统计 mlsql 官网不同页面的访问 PV，取 TOP 10，统计结果通过附件的方式发送到邮件。

#### **Step1、测试**数据集

测试数据 Nginx 访问日志文件：`access.log`

**日志格式**：

```Perl
-- 0.0.0.0 - mlsql-docs.kyligence.io - [11/Sep/2021:17:38:56 +0000] "GET /2.1.0/zh-hans/algs/linear_regression.html HTTP/1.1" 200 71714 "-" "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.htm)" "-"
```

#### **Step2、**上传数据

我们下面会通过 MLSQL LAB 的上传功能，上传我们的Nginx日志。

> MLSQL LAB入口：https://lab.mlsql.tech/#/notebook/245

通过 `Home -> Upload` 进行上传：

![img](../zh-cn/images/sendMessage.assets/(null)-20220129183514596.(null).jpeg)

将文件拖拽到上传框后，点击 `Submit` 就可以了。系统提示你上传成功，你可以通过命令行查看。不过我们可以到直接进入 `Sata Catalog -> File System` 查看：

![img](../zh-cn/images/sendMessage.assets/(null)-20220129183514550.(null).jpeg)



可以看到，我们上传的文件已经在  `/tmp/upload` 里了。

> 需要注意的是，我们的 FileSystem 并不是本地路径的概念，/tmp/upload 是一个相对路径，而 FileSystem 是对文件系统的封装，用于适配不同的文件系统。其绝对地址是由内置的数据湖配置（streaming.deltalake.path）决定的，Engine 端可以根据数据湖路径位置，使用本地存储系统，也可以在 spark/conf 里设置 hdfs-site.xml 等配置文件，配置远程存储，亦或是使用 Juicefs 挂载任意对象存储。



#### **Step3、开发SQL**

```Ruby
load text.`/tmp/upload/nginx.log` as nginxTable;

 

-- 日志文件的清洗和统计

select 

  access_host,access_page,count(1) as access_freq 

from (

    select split(value,' ')[2] as access_host,split(value,' ')[7] as access_page 

    from (select * from nginxTable where value is not null)

  )

where 

  access_host !="-"

group by access_host,access_page 

order by access_freq desc

limit 10 as accessTable;



set savePath="/tmp/access.csv";

set saveDir="/tmp/access";



-- 保存PV统计数据为CSV格式的文件

save overwrite accessTable as csv.`${saveDir}` where header="true";



-- 因为在分布式环境运行，我们的文件会按照分区个数保存为多个文件，这里我们进行合并

!hdfs -getmerge /tmp/access /tmp/access.csv;



set EMAIL_TITLE = "MLSQL网站访问日志分析"; 

set EMAIL_BODY = '''<div>Hi All,<br/><br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;日志分析完成，请查收邮件！</div><br/><hr/><div>Thanks,<br/>The MLSQL Opensource Team</div>''';

set EMAIL_TO = "userAccountNumber@qq.com, userAccountNumber@163.com";



-- 发送附件邮件到指定邮箱

run command as SendMessage.``

where method="mail"

and content="${EMAIL_BODY}"

and from = "userAccountNumber@qq.com"

and to = "${EMAIL_TO}"

and subject = "${EMAIL_TITLE}"

and contentType="text/html"

and attachmentContentType="text/csv"

and attachmentPaths="${savePath}"

and smtpHost = "smtp.qq.com"

and smtpPort="587"

and `properties.mail.smtp.starttls.enable`= "true"

and `userName`="userAccountNumber@qq.com"

and password="***"

;
```

附件地址： [nginx.log](https://kyligence.feishu.cn/file/boxcnnzO88foC6hdab94Gyi5ROd)



上面的代码应该还是非常清晰易懂的，具体流程如下：

- 首先在第1行代码中加载前面上传好的日志文件，在第4行中进行日志文件的清洗和统计，这里我们使用了比较简单的 split 的方式，实际会有更加复杂的情况，Byzer-lang提供了python脚本，ET，UDF等能力给予用户，方便其实现更加适合复杂数据的清洗逻辑。



- 在19行中使用 set 语法设置一个变量，为统计结果的输出地址，然后我们可以用 save 语法将 csv 文件保存到数据湖中。由于任务在计算的时候会产生多个分区，保存到数据湖会有多个文件，我们使用宏命令 `!hdfs` 将数据进行合并。



- 在38行使用SendMessage发送邮件到QQ邮箱，通过 `attachmentPaths="${savePath}"` 设置附件内容。



- 最后，我们设置一下SMTP协议使用的相关参数，完成邮件的发送。



#### **Step4、邮件发送完毕，验证结果**

我们来看下实际发送的邮件，是不是我们预期的效果。

![img](../zh-cn/images/sendMessage.assets/(null)-20220129183514615.(null).jpeg)

我们从测试数据中，统计到了PV TOP 10的页面：

无法复制加载中的内容

使用上面的Byzer-lang代码，我们轻松的完成了从数据导入->数据清洗->数据分析->数据导出的全流程，如果我们通过load抽取某一个固定的数据源，结合Byzer notebook即将集成的调度能力，马上就变成了一个企业级的自主化报表系统。







## Join Byzer Community

加入我们的slack channel！

https://join.slack.com/t/byzer-org/shared_invite/zt-10qgl60dg-lX4fFggaHyHB6GtUmer_xw

也欢迎大家扫码添加小助手，加入 Byzer 用户群讨论、交流问题哦～

![img](../zh-cn/images/sendMessage.assets/(null)-20220129183514590.(null).jpeg)