# 利用 Byzer 的10行代码轻松实现企业级邮件服务



| Version | Author          | Date       | Comment          |
| ------- | --------------- | ---------- | ---------------- |
| V 1.0   | @Lin Zhang 张琳 | 2021/11/11 |                  |
| V 2.0   | @Lin Zhang 张琳 | 2022/1/9   | 更新为最新的文章 |
| V 3.0   | @Lin Zhang 张琳 | 2022/2/7   | 修改标题和修改示例代码 |

**Byzer**（又称 **Byzer-lang**）是一个面向大数据和 AI 的云原生分布式语言，具备数据管理，商业分析，机器学习等能力。Byzer-lang 内置了大量的插件可以帮我们完成很多有价值的工作，使用 Byzer-lang 的几句简单代码就可以让您快速完成功能验证和新需求的开发。用户也可以可通过插件商店获取更多能力亦或是自定义插件轻松实现个性化的场景拓展。



今天我们主要来介绍下 Byzer-lang 中被高频使用的邮件插件 **SendMessage** ，同时介绍下载对 nginx 日志做 PV 统计时，我们如何将统计结果通过邮件发送给指定的用户。



> Byzer-lang项目地址 : https://github.com/byzer-org/byzer-lang



## Why Byzer-lang ？

传统分析型的报表系统，开发流程非常长，需要较多人工维护成本和迭代成本。一般会有一个邮件服务，该服务会定制开发一套 DSL 语法，用于在交互层面方便用户在邮件模板中使用，如：查询 SQL、调度周期语法糖、自定义参数、公共参数等。然后会有一个调度框架周期性触发邮件任务计算。下面笔者举一个具体的业务流程示例：

1. 用户在数据平台上通过使用 DSL 配置好一个邮件任务，并设置输入源等配置信息。输入源一般来自数据仓库 DM 层（数据集市层）或者 DWS（分析层）。
2. 日志通过分布式日志上报服务上传日志数据到 hdfs。
3. 通过分布式计算引擎（spark, flink 等）读取日志做清洗和计算工作，产出一张 DWS 使用的表。
4. 当调度框架（Fuxi, Azkaban 等）满足调度周期或者调度依赖关系后，触发邮件任务。
5. 邮件服务接收到邮件任务后，根据邮件模板配置的调度周期等信息仿真 Hive SQL，查询该分析层的表数据并进行计算，生成邮件内容发送邮件。
6. 对应的邮件服务器收到邮件，推送到用户手机。



![img](../zh-cn/images/sendMessage.assets/(null)-20220129183514495.(null).jpeg)



我们发现上述流程非常复杂，那有没有快速简洁的方式，无需多方合作，无需定制化开发，就能完成一个企业级可复用的邮件服务工具呢？

这时 Byzer-lang 的优势便体现出来了。只需几行代码，就能完成上述复杂的流程。

接下来让我们结合一个 nginx 日志分析的场景来看看 Byzer-lang 是如何高效简洁地完成上述任务的。



## What is SendMessage ET ？

> **ET** 是 Byzer 语言内置 Estimator/Transformer 的简称。

[SendMessage](http://mlsql-docs.kyligence.io/latest/zh-hans/process/estimator_transformer/SendMessage.html) 是我们常用的发送消息的 ET，目前支持邮件的方式。除此之外，我们还有一个单独的 ET（FeishuMessageExt）支持飞书消息，后续也会支持更多的 SNS 工具的消息交互。本节内我们先了解下邮件ET的使用方式。



### **1、配置参数**



本小节中，将详细介绍 SendMessage 这个 ET 插件中的具体参数，了解参数具体含义，方便我们在后续代码中使用 SendMessage 把分析好的 PV 报表用邮件的方式发送出去。



> 红色字体参数为必填项。

无法复制加载中的内容

发送邮件支持2种方式，分别如下：



- local: 连接本地 sendmail 服务器的方式。需要用户在本地服务器部署 sendmail 服务，并配置好用户名、授权码等信息，在 Byzer 中会连接本地服务发送邮件。通过 sendmail 服务我们可以灵活地选择 MDA（邮件投递代理）或者 MTA（邮件服务器）来处理邮件。



- config: 配置 SMTP 服务器的方式。在 Byzer 中配置邮箱用户名和邮箱授权码、邮箱 SMTP 服务器地址、端口，通过授权码登录第三方客户端邮箱。如果使用个人或者企业邮箱推荐使用该方式。



### **2、如何使用**

在开始开发一个PV统计任务之前，我们先看一个简单的代码示例，**仅需 10 行左右的配置代码就可以完成数据结果的在线邮件推送**：

```SQL
set EMAIL_TITLE = "这是邮件标题";

set EMAIL_BODY = "Byzer 任务 xx 运行完成，请及时查询结果";

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

-- 设置邮件客户端的协议为 SSL 协议，默认为 SSL 协议，也可选择 TLS 配置：

--`properties.mail.smtp.starttls.enable`= "true"

and `properties.mail.smtp.ssl.enable`= "true"

and userName = "userAccountNumber@qq.com"

and password="***"

;
```



> 其中，userAccountNumber 代表用户邮箱账号。



### 3、如何获取邮箱授权码（password）

不同邮箱获取授权码的方式不同，我们以`QQ邮箱`为例，首先访问 `设置 - 账户 - POP3/IMAP/SMTP/Exchange/CardDAV/CalDAV服务`，然后找到下图所示的菜单，开启 POP3/SMTP 服务，并点击`生成授权码`。

![img](../zh-cn/images/sendMessage.assets/(null)-20220129183514618.(null).jpeg)

**想了解更多详细的使用说明，参考 Byzer-lang 官网文档：****[如何发送邮件](https://docs.byzer.org/#/byzer-lang/zh-cn/extension/et/SendMessage?id=如何发送邮件)**



了解完具体的使用方式，我们来看下怎么使用邮件插件来处理具体的业务问题吧。



### 4、Example

模拟需求为：统计 Byzer 官网不同页面的访问 PV，取 TOP 10，统计结果通过邮件附件的方式发送到指定邮箱。

#### **Step1、测试**数据集

首先，我们准备好一份演示使用的 nginx 模拟日志文件，文本内容如下：

```Nginx
127.0.0.1 - _ - [11/Sep/2021:17:42:36 +0000] "\x05\x01\x00" 400 157 "-" "-" "-"

127.0.0.1 - docs.byzer.org - [11/Sep/2021:17:42:43 +0000] "GET https://docs.byzer.org/ HTTP/1.1" 403 153 "-" "curl/7.58.0" "-"

127.0.0.1 - 127.0.0.1 - [11/Sep/2021:18:17:38 +0000] "GET /phpmyadmin4.8.5/index.php HTTP/1.1" 403 555 "-" "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3464.0 Safari/537.36" "-"

127.0.0.1 - www.byzer.org - [11/Sep/2021:18:26:31 +0000] "GET / HTTP/1.1" 200 2343 "-" "Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.116 Mobile Safari/537.36" "-"

127.0.0.1 - www.byzer.org - [11/Sep/2021:18:26:32 +0000] "GET /static/css/main.736717e4.chunk.css HTTP/1.1" 200 4273 "http://www.byzer.org/" "Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.116 Mobile Safari/537.36" "-"

127.0.0.1 - www.byzer.org - [11/Sep/2021:18:26:32 +0000] "GET /static/js/main.35f9529f.chunk.js HTTP/1.1" 200 21286 "https://www.byzer.org/" "Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.116 Mobile Safari/537.36" "-"

127.0.0.1 - 127.0.0.1 - [11/Sep/2021:17:44:24 +0000] "HEAD http://127.0.0.1/ HTTP/1.1" 400 0 "-" "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36" "-"
```

可以将上面的文本复制到本地并保存成一份 text 文件，我们命名为：**access_log.txt**。



#### **Step2、**上传数据

下面会通过 Byzer Notebook 的 Data Catalog 中的上传功能，上传我们的 `access_log.txt` 日志文件。

> Byzer Notebook 注册试用入口：https://www.byzer.org/home

通过 `Home -> Upload` 进行上传：

![img](../zh-cn/images/sendMessage.assets/(null)-20220129183514596.(null).jpeg)



将文件拖拽到上传框后，点击 `Submit` 就可以了。系统提示你上传成功，你可以通过命令行或者Notebook的文件系统查看。使用文件系统，可以到` ``D``ata ``C``atalog -> File System` 查看：

![img](../zh-cn/images/sendMessage.assets/(null)-20220129183514550.(null).jpeg)



可以看到，我们上传的文件已经在  `/tmp/upload` 里了。

> 需要注意的是，我们的 FileSystem 并不是本地路径的概念，/tmp/upload 是一个相对路径，而 FileSystem 是对文件系统的封装，用于适配不同的文件系统。其绝对地址是由内置的数据湖配置（streaming.deltalake.path）决定的，Engine 端可以根据数据湖路径位置，使用本地存储系统，也可以在 spark/conf 里设置 hdfs-site.xml 等配置文件，配置远程存储，亦或是使用 Juicefs 挂载任意对象存储。



#### **Step3、开发邮件任务**

```Ruby
load text.`/tmp/upload/access_log.txt` as nginxTable;

 

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



set saveDir="/tmp/access";

set savePath="/tmp/access.csv";



-- 保存PV统计数据为CSV格式的文件

save overwrite accessTable as csv.`${saveDir}` where header="true";



-- 因为在分布式环境运行，我们的文件会按照分区个数保存为多个文件，这里我们进行合并

!hdfs -getmerge /tmp/access/tmp/access.csv;



set EMAIL_TITLE = "Byzer网站访问日志分析"; 

set EMAIL_BODY = '''<div>Hi All,<br/><br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;日志分析完成，请查收邮件！</div><br/><hr/><div>Thanks,<br/>The Byzer Org</div>''';

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

and `properties.mail.smtp.ssl.enable`= "true"

and `userName`="userAccountNumber@qq.com"

and password="***"

;
```



上面的代码应该还是非常清晰易懂的，具体流程解释如下：

- 首先加载前面上传好的日志文件，在第4行中进行日志文件的清洗和统计，这里我们使用了比较简单的 split 的方式，实际会有更加复杂的情况，Byzer-lang 提供了 python 脚本，ET，UDF 等能力给予用户，方便其实现更加适合复杂数据的清洗逻辑。



- 在第16行中使用 set 语法设置一个变量，为统计结果的输出地址，然后我们可以用 save 语法将 csv 文件保存到数据湖中。由于任务在计算的时候会产生多个分区，保存到数据湖会有多个文件，我们使用宏命令 `!hdfs` 将数据进行合并。



- 第29行中，使用SendMessage发送邮件到QQ邮箱，通过 `attachmentPaths="${savePath}"` 设置附件内容。



- 最后，我们设置一下 SMTP 协议使用的相关参数，完成邮件的发送。



#### **Step4、邮件发送完毕，验证结果**

我们来看下实际发送的邮件，是不是我们预期的效果。

![img](../zh-cn/images/sendMessage.assets/(null)-20220129183514615.(null).jpeg)

**可以看到，我们已经成功地通过 Byzer Notebook 将分析结果发送到了对应的邮箱！**

我们从模拟测试数据中，统计到了 PV TOP 10 的页面：



| access_host                             | access_page                         | access_freq |
| --------------------------------------- | ----------------------------------- | ----------- |
| 127.0.0.1                               | /phpmyadmin4.8.5/index.php          | 1           |
| [www.byzer.org](http://www.byzer.org)   | /static/css/main.736717e4.chunk.css | 1           |
| [www.byzer.org](http://www.byzer.org)   | /                                   | 1           |
| [www.byzer.org](http://www.byzer.org)   | /static/js/main.35f9529f.chunk.js   | 1           |
| _                                       | 400                                 | 1           |
| [docs.byzer.org](http://docs.byzer.org) | https://docs.byzer.org/             | 1           |
| 127.0.0.1                               | http://127.0.0.1/                   | 1           |


使用上述的 Byzer-lang 教程，我们轻松地完成了从 数据导入->数据清洗->数据分析->数据导出->邮件发送 的全流程。由此我们可以衍生同类型的应用方式，即通过 load 抽取某个或多个数据源中的数据，结合 Byzer Notebook 即将集成的调度能力，立马就可以产出一个企业级的自动化报表系统，是不是很酷呢！～