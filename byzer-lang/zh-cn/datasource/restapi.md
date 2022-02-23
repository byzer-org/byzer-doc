# REST API

Byzer 创造性地支持将 REST API 作为数据源，并将返回值注册为一张表。

REST API 支持重试机制，支持取返回值中的字段进行多次请求，并将所有返回值组合成一张表。

下面是一个简单的例子：
```sql
> SET CLIENT_ID = `select CLIENT_ID from token` where type='sql' and mode = 'runtime';
> SET CLIENT_SECRET = `select CLIENT_SECRET from token` where type='sql' and mode = 'runtime';
> SET REFRESH_TOKEN = `select REFRESH_TOKEN from token` where type='sql' and mode = 'runtime';

> SET JIRA_URL="https://auth.atlassian.com/oauth/token";
> LOAD Rest.`$JIRA_URL` 
 where `config.connect-timeout`="10s"
 and `config.method`="POST"
 and `header.content-type`="application/json"
 and `body`='''{ 
  "grant_type": "refresh_token",
  "client_id": "${CLIENT_ID}",
  "client_secret": "${CLIENT_SECRET}",
  "refresh_token": "${REFRESH_TOKEN}"
 }
'''
as token_1;
```

在这个例子中，首先我们通过 SET 语法运行时执行 Byzer 的语法获取 3 个参数，详细这个语法了解请翻看 [set 语法](/byzer-lang/zh-cn/grammar/set.md)。

在 load 语句中，我们使用 `Rest` 关键字标志数据源是 REST API，引号內填写访问 URL，当然也可以引用 SET 变量。

在 load 语句中 使用 `where` 从句设置参数。
`config.connect-timeout` 代表设置超时时间为 10s，
`config.method` 设置请求的方法为 POST，`header.content-type` 设置请求的内容格式，
`body` 设置 post 请求的 body，
最后把返回值注册为一张名为 token_1 的表。

## 参数设置

参数可以分为3类：
- config：设置 rest 请求信息，如 `method`/`timeout` 等
- header：设置请求头
- body/form：设置请求参数，随 `method`/`content-type` 不同而变化 

**基础参数列表**

|参数|是否必须|说明|
|---|-------|---|
|config.method|必须| rest 请求的方法，可选 GET/POST/PUT|
|config.socket-timeout|非必需| socket 连接时间，填写带单位的时间如 10s|
|config.connect-timeout|非必需|连接超时时间，填写带单位的时间如 10s|
|header.Content-Type|非必需| method 为 POST 时，默认为 application/x-www-form-urlencoded; GET 时，默认为 application/json |
|header.${user_define}|非必需| 通过这种方式可以自定义的设置请求头|
|form.${user_define}|非必需| Content-Type 为 application/x-www-form-urlencoded 时，通过这种方式设置参数|
|body|非必需| Content-Type 为 application/json 时，通过这种方式设置请求体|

> **注意：**所有参数值都必须是字符串，也就是必须用 `""` 或者 `'''` 括起来。参数值可以使用 `SET` 得到的变量

## 高级参数设置

Byzer 支持取返回值中的字段进行多次请求，并将所有返回值组合成一张表。
下面是一个简单的例子：

```sql
> SET acc_ko = `SELECT get_json_object(string(content),'$.access_token')  FROM token_1 AS token_2` WHERE type = "sql" and mode = "runtime";

> LOAD Rest.`$url` where
`config.connect-timeout`="10s"
 and `config.socket-timeout`="10s"
 and `config.method`="GET"
 and `header.Authorization`='''Bearer $acc_ko'''
 and `header.Content-Type`= "application/json"
 and `config.page.next`="{0}"
 and `config.page.values`="$.nextPage"
 and `config.page.limit`="10"
 AS worklog_del;
```

在这个例子中，我们首先通过 `SET` 语法将上个例子中获取到的 token 设置为变量。这里利用了[SparkSQL Build-in Function](https://spark.apache.org/docs/latest/api/sql/)。
紧接着我们使用 `load` 语法 `Rest` 工具进行多次请求。
下面详细讲解用到的参数：

**`config.page.values`**

是返回结构中下一页的关键信息，使用[JsonPath语法](https://github.com/json-path/JsonPath)。
你可以指明多个关键信息，并在`config.page.next`中使用他们。

**`config.page.next`**

表示下次请求的 url，你可以用 {0},{1}... {n} 代表 `config.page.values` 获取的若干信息，并直接写到请求字符串中，如：
```sql
config.page.next="http://www.example.com/rest/{0}/deleted?projects={1}"
```
如果 `$.nextPage` 路径下就是请求链接，则可以像例子一样直接写：
```sql
config.page.next="{0}"
```

**`config.page.interval`**

表示多次请求时的请求间隔。一些 SAAS 服务会对请求进行限流，如 120s 內只允许 100 次请求，这时可以设置这个参数为 `1200ms` 或 `1.2s`。

默认值为 `10ms`。

**`config.page.limit`**

表示请求次数/页数，默认为 `1` 次。



## 返回值

load 语句将请求的返回值设置为一张表。其中有两列：
- content：base64编码的返回体
- status：http 状态码

如下所示：

|content | status |
|--------|--------|
|  (base64 encode content)| (http status)|

如果是多次请求，则返回表会有多行，每行代表一次请求的结果。
你可以使用 [SparkSQL Build-in Function](https://spark.apache.org/docs/latest/api/sql/) 或自定义 UDF 对他们进行聚合和其他操作。