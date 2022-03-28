# 发送邮件插件/SendMessage 


### 什么是 SendMessage ET ？

> **ET** 是 Byzer 语言内置 Estimator/Transformer 的简称。

**SendMessage** 是我们常用的发送消息的 ET，目前支持邮件的方式。除此之外，我们还有一个单独的 ET（FeishuMessageExt）支持飞书消息，后续也会支持更多的 SNS 工具的消息交互。本节内我们先了解下邮件 ET 的使用方式。


**使用场景示例：**

- 数据计算处理后，生成下载链接，发邮件给相关人员
- 数据量较少的情况，可以直接发送数据处理结果

### 为什么选择 Byzer-lang ？
传统分析型的报表系统，开发流程非常长，需要较多人工维护成本和迭代成本。一般会有一个邮件服务，该服务会定制开发一套 DSL 语法，用于在交互层面方便用户在邮件模板中使用，如：查询 SQL、调度周期语法糖、自定义参数、公共参数等。然后会有一个调度框架周期性触发邮件任务计算。

我们发现上述流程非常复杂，那有没有快速简洁的方式，无需多方合作，无需定制化开发，就能完成一个企业级可复用的邮件服务工具呢？
这时 Byzer-lang 的优势便体现出来了。只需几行代码，就能完成上述复杂的流程。

**接下来让我们结合一个 nginx 日志分析的场景来看看 Byzer-lang 是如何高效简洁地完成上述的报表开发和邮件服务任务的。**

### I. 配置参数

了解参数具体含义，方便我们在后续代码中使用 SendMessage 把分析好的 PV 报表用邮件的方式发送出去。

> 红色字体参数为必填项。

| 参数名  |  参数含义 |
|---|---|
| method | 消息发送方式，目前支持：MAIL（邮件发送）；默认值为MAIL |
| mailType | 邮件服务类型，目前支持：local（使用本地sendmail服务）、config（sql配置SMTP服务器）；默认值为 config |
| userName | 邮箱服务用户名，即邮箱账号，如：do_not_reply@gmail.com；如果为config模式该值必填。 |
| password | 邮箱服务授权码；如果为config模式该值必填。 |
| <font color='red'> from </font> | 发件人邮箱账户 |
| <font color='red'> to </font> | 收件人邮箱账户，多个账户使用','分隔 |
| cc | 抄送人邮箱账户，多个账户使用','分隔 |
| subject | 邮件标题 |
| content | 邮件内容 |
| contentType | 邮件内容的格式，目前支持标准的Java Mail Content-Type，如：text/plain、text/html、text/csv、image/jpeg、application/octet-stream、multipart/mixed |
| attachmentContentType | 邮件附件内容的格式，目前支持标准的Java Mail Content-Type |
| attachmentPaths | 邮件附件地址，多个地址使用','分隔 |
| smtpHost | SMTP邮件服务域名；如果为config模式该值必填。 |
| smtpPort | SMTP邮件服务端口号；如果为config模式该值必填。 |
| properties.[邮件客户端配置] | javaMail邮件客户端配置，常用配置如：properties.mail.debug、properties.mail.smtp.ssl.enable、properties.mail.smtp.ssl.enable、properties.mail.smtp.starttls.enable等 |



发送邮件使用 run 语法，我们目前支持 2 种方式，分别如下：

- **local**: 连接本地 sendmail 服务器的方式。需要用户在本地服务器部署 sendmail 服务，并配置好用户名、授权码等信息，在byzer中会连接本地服务发送邮件。通过 sendmail 服务我们可以灵活的选择 MDA（邮件投递代理）或者 MTA（邮件服务器）来处理邮件。                           
- **config**: 配置 SMTP 服务器的方式。在 Byzer 中配置邮箱用户名和邮箱授权码、邮箱 SMTP 服务器地址、端口，通过授权码登录第三方客户端邮箱。如果使用个人或者企业邮箱推荐使用该方式。

> 在 Byzer config 模式中，使用的邮件用户代理（ Mail User Agent, 简称 MUA ）客户端程序是 JavaMail-API。



### II、获取邮箱授权码（password）

#### 1. 什么是授权码？

授权码是用于登录第三方客户端的专用密码。

适用于登录以下服务：POP3/IMAP/SMTP/Exchange/CardDAV/CalDAV服务。

> 注意：大部分邮件服务为了你的帐户安全，更改账号密码会触发授权码过期，需要重新获取新的授权码登录。

#### 2. 为什么需要邮箱授权码（password）

使用客户端连接邮箱 SMTP 服务器时，可能存在邮件泄露风险，甚至危害操作系统的安全，大部分邮件服务都需要我们提供授权码，验证用户身份，用于登录第三方客户端邮箱发送邮件。

不同邮箱获取授权码的方式不同，我们以`QQ邮箱`为例，首先访问 `设置 - 账户 - POP3/IMAP/SMTP/Exchange/CardDAV/CalDAV服务`，然后找到下图所示的菜单，开启 POP3/SMTP 服务，并点击`生成授权码`。

  <img src="/byzer-lang/zh-cn/extension/et/images/qq_mail_identify_code.png" alt="qq_mail_indentify_code.png"/>

#### 3. 如何获取 smtpHost、smtpPort

不同邮箱获取授权码的方式不同，我们可以很容易在用户手册中找到邮箱提供的SMTP服务器。以QQ邮箱为例，QQ邮箱 POP3 和 SMTP 服务器地址设置如下：

| 类型       | 服务器名称 | 服务器地址  | 非SSL协议端口号 | SSL协议端口号 | TSL协议端口 |
| ---------- | ---------- | ----------- | --------------- | ------------- | ----------- |
| 发件服务器 | SMTP       | smtp.qq.com | 25              | 465           | 587         |
| 收件服务器 | POP        | pop.qq.com  | 110             | 995           | -           |
| 收件服务器 | IMAP       | imap.qq.com | 143             | 993           | -           |

如果使用的是163邮箱，则相关服务器信息：

  <img src="/byzer-lang/zh-cn/extension/et/images/163_mail_identify_code.png" alt="163_mail_indentify_code.png"/>

> 注意：每个邮件厂商的smtp服务都有自己的实现，不同的厂商端口号对应的协议可能不同，比如端口587，在qq中使用的TSL协议，而在163中使用的是SSL协议，请以官方使用说明为准。



### III. 如何使用

在开始开发一个 PV 统计任务之前，我们先看一个简单的 config 方式的代码示例，仅需 10 行左右的配置代码就可以完成数据结果的在线邮件推送：

```sql
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



我们也支持使用本地邮件服务的方式，方式如下：

```sql
run command as SendMessage.``
where method = "mail"
and mailType="local"
and content = "${EMAIL_BODY}"
and from = "yourMailAddress@qq.com"
and to = "${EMAIL_TO}"
and subject = "${EMAIL_TITLE}"
;
```



同时，SendMessage 还支持使用邮件发送 HTML 格式的文本，并携带附件。

示例如下：

1） 首先通过 Byzer Notebook 上传 2 个 CSV 文件`employee.csv`和`company.csv`，作为附件内容。

2） 通过如下 SQL 的方式发送该邮件

```sql
set EMAIL_TITLE = "这是邮件标题";
set EMAIL_BODY = '''<div>这是第一行</div><br/><hr/><div>这是第二行</div>''';
set EMAIL_TO = "yourMailAddress@qq.com";

run command as SendMessage.``
where method="mail"
and content="${EMAIL_BODY}"
and from = "yourMailAddress@qq.com"
and to = "${EMAIL_TO}"
and subject = "${EMAIL_TITLE}"
and contentType="text/html"
and attachmentContentType="text/csv"
and attachmentPaths="/tmp/employee.csv,/tmp/employee.csv"
and smtpHost = "smtp.qq.com"
and smtpPort="587"
and `properties.mail.smtp.starttls.enable`= "true"
and `userName`="yourMailAddress@qq.com"
and password="---"
;
```



### IV. 完整 Example 示例

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

下面会通过 Byzer Notebook 的数据目录中的上传功能，上传我们的 `access_log.txt` 日志文件。

> Byzer Notebook 注册试用入口：https://www.byzer.org/home

点击顶栏中的**主页**，再点击**上传**：

  <img src="/byzer-lang/zh-cn/extension/et/images/demo1.png" alt="qq_mail_indentify_code.png"/>

将文件拖拽到上传框后，点击**提交**就可以了。上传成功后，您可以通过命令行查看上传的文件，也可以进入**工作区**，找到侧边栏中的**数据目录**模块，在 **File System** 中查看：

<p align="center">
    <img src="/byzer-lang/zh-cn/extension/et/images/demo2.png" alt="qq_mail_indentify_code.png" alt="name"  width="250"/>
</p>


可以看到，我们上传的文件已经在  `/tmp/upload`   里了。

> 需要注意的是，我们的 FileSystem 并不是本地路径的概念，/tmp/upload 是一个相对路径，而 FileSystem 是对文件系统的封装，用于适配不同的文件系统。其绝对地址是由内置的数据湖配置（streaming.deltalake.path）决定的，Engine 端可以根据数据湖路径位置，使用本地存储系统，也可以在 spark/conf 里设置 hdfs-site.xml 等配置文件，配置远程存储，亦或是使用 Juicefs 挂载任意对象存储。



#### **Step3、开发邮件任务**

```sql
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



####  **Step4、邮件发送完毕，验证结果**

我们来看下实际发送的邮件，是不是我们预期的效果。

<p align="center">
    <img src="/byzer-lang/zh-cn/extension/et/images/demo3.png" alt="qq_mail_indentify_code.png" alt="name"  width="600"/>
</p>

**可以看到，我们已经成功地通过 Byzer Notebook 将分析结果发送到了对应的邮箱！**

我们从模拟测试数据中，统计到了 PV TOP 10 的页面：

<p align="center">
    <img src="/byzer-lang/zh-cn/extension/et/images/demo4.png" alt="qq_mail_indentify_code.png" alt="name"  width="600"/>
</p>


使用上述的教程，我们轻松地完成了从 **数据导入->数据清洗->数据分析->数据导出->邮件发送** 的全流程。由此我们可以衍生同类型的应用方式，即通过 load 抽取某个或多个数据源中的数据，结合 Byzer Notebook 即将集成的调度能力，就可以高效地产出一个企业级的自动化报表系统。
