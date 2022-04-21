### 更多 REST API 调用示例


Rest 数据源可以让 Byzer-lang 脚本更加灵活，可以使用该数据源完成非常复杂的 REST API 交互。Rest 数据源支持简单的 REST API 调用，也支持直接在 Rest 数据源中实现分页数据的读取。


#### 1. 使用 POST 方法将 json string 作为 Request body

下述例子是调用 Byzer 引擎的 `/run/script` 的 api，来执行一段 byzer 的 sql 脚本，`body` 参数的值是 request body，在其中填写了 `/run/script` 这个请求的参数

```sql
SET ENGINE_URL="http://127.0.0.1:9003/run/script"; 

load Rest.`$ENGINE_URL` where

 `config.connect-timeout`="10s"

 and `config.method`="post"

 and `header.content-type`="application/json"

 and `body`='''

 { 

   "executeMode": "query",

   "sql": "select 1 as a as b;",

   "owner": "admin",

   "jobName": "f39ba3b2-0a28-4aa2-806e-5412813c995b"

 }

'''

as table1;

-- 获取接口返回结果

select status, string(content) as content  

from table1 as output;
```

执行结果：

| status | content     |
| ------ | ----------- |
| 200    | [{"a":"1"}] |




#### 2. 使用 GET 发起 Form 表单请求

下面这个例子展示了使用 cnnodejs 的一个 api 来获取 topics 相关的内容，其中请求参数是通过 `form` 的参数进行传递的

```sql
SET TOPIC_URL="https://cnodejs.org/api/v1/topics"; 

load Rest.`$TOPIC_URL` where

 `config.connect-timeout`="10s"

 and `config.method`="get"

 -- will retry 3 times if api call failed

 and `config.retry`="3"

 -- below lists the parameters of form

 and `form.page`="1"

 and `form.tab`="share"

 and `form.limit`="2"

 and `form.mdrender`="false" 

as cnodejs_articles;


-- decode API response from base64 string to a json string
select string(content) as content from cnodejs_articles as response_content;

-- expand the json string 
run response_content as JsonExpandExt.`` where inputCol="content" and structColumn="true" as cnodejs_articles;

-- retrieve user infomation and process as a table
select content.data from cnodejs_articles as cnodejs_articles_info;
```

在这里，我们发起了 get 请求，请求参数可以放到 URL 里，也可以放到`form.[key]` 里。这些参数最终会被拼接到 URL 中。

执行结果：

| data |
| ------ |
| [ { "author": { "avatar_url": "https://avatars.githubusercontent.com/u/156269?v=4&s=120", "loginname": "fengmk2" }, "author_id": "4efc278525fa69ac6900000f", "content": "https://registry.npmmirror.com 中国 npm 镜像源在2013年12月开始就使用基于 koa 的 https://github.com/cnpm/cnpmjs ......    |



#### 3. 设置动态渲染参数

动态渲染参数可以在 `:{....}` 中执行代码。其语法和 if/else 里的条件表达式相同，用于返回一个变量，该变量会以字符串形式返回。所以可以写的更复杂，比如：

```sql
and `form.created`=''':{select split(:create_at,":")[0] as :ca; :ca}'''
```

渲染动作产生在运行时，所以可以很方便的获取的参数。

下面我们看一个具体的例子：

```sql
SET TOPIC_URL="https://cnodejs.org/api/v1/topics"; 

load Rest.`$TOPIC_URL` where

 `config.connect-timeout`="10s"

 and `config.method`="get"

 and `form.page`=''':{select 1 as :b;:b}'''

 and `form.tab`="share"

 and `form.limit`="2"

 and `form.mdrender`="false" 

as cnodejs_articles;


select status, string(content) as content  

from cnodejs_articles as output;
```



在 `form.page` 参数中我们设置的代码包含一段表达式：

```sql
 and `form.page`=''':{select 1 as :b;:b}'''
```

其中的`:{select ``1`` as :b;:b}`会动态执行，并将结果渲染到模板代码中，则实际执行的 SQL 内容变成了：

```sql
 and `form.page`='''1'''
```

所有 form 参数都支持动态渲染参数。



#### 4. 如何解析结果集

下面演示一个结果集解析的 demo，为了方便处理JSON结果集，我们结合 JsonExpandExt ET 和 explode 函数，代码示例如下所示：

```sql
SET ENGINE_URL="https://cnodejs.org/api/v1/topics";

load Rest.`$ENGINE_URL` where

  `config.connect-timeout`="10s"

  and `config.method`="get"

  and `form.page`=''':{select 1 as :b;:b}'''

  and `form.tab`="share"

  and `form.limit`="2"

  and `form.mdrender`="false"

as raw_cnodejs_articles;


select status, string(content) as content

from raw_cnodejs_articles as temp_cnodejs_articles;


-- 提取 JSON 结构内容（也就是 condejs 列表页面内容）并将其保存为 struct field 以便我们使用 JSON 数据

run temp_cnodejs_articles as JsonExpandExt.``

where inputCol="content" and structColumn="true"

as cnodejs_articles;


-- 转换列表页上的一行数据来操控行（即展开嵌套的 JSON 数据）
select explode(content.data) as article from cnodejs_articles as articles;
```



结果如下：

![img.png](images/img.png)

我们可以看到，我们很容易将表展开，从而实现更复杂的需求。



#### 5. 分页数据的读取

我们以 Node.js 专业中文社区的列表页为例，代码如下所示：

```sql
SET ENGINE_URL="https://cnodejs.org/api/v1/topics"; 

load Rest.`$ENGINE_URL` where

`config.connect-timeout`="10s"

and `config.method`="get"

and `form.page`=''':{select 1 as :b;:b}'''

and `form.tab`="share"

and `form.limit`="2"

and `form.mdrender`="false"


and `config.page.next`="https://cnodejs.org/api/v1/topics?page={0}"

and `config.page.skip-params`="false"

-- 自动增量这项特殊配置是为了自动增加页数而设计。`:1` 意味着页数值从1开始。

and `config.page.values`="auto-increment:1"

and `config.page.interval`="10ms"

and `config.page.retry`="3"

and `config.page.limit`="2"


as raw_cnodejs_articles;


set status= `select status from raw_cnodejs_articles` where type="sql" and mode="runtime";



-- 如果状态不是200，则模拟不带数据的新表

!if ''' :status != 200 '''; 

!then; 

    run command as EmptyTableWithSchema.`` where schema='''st(field(content,binary),field(status,integer))''' as raw_cnodejs_articles;    

!fi;



select status, string(content) as content  

from raw_cnodejs_articles as temp_cnodejs_articles;



run temp_cnodejs_articles as JsonExpandExt.`` 

where inputCol="content" and structColumn="true" 

as cnodejs_articles;



select explode(content.data) as article from cnodejs_articles as articles;



select count(article.id) from articles as output;
```



结果如下，可以看到有 6 条数据，一共进行了三次分页

![img_1.png](images/img_1.png)


对于那种需要从结果集获取分页参数的，则可以使用 jsonpath 进行抽取并且进行渲染，相关配置如下：

```sql
-- 为了得到 `cursor` 和 `wow` 在 page.next 中使用动态参数。

and `config.page.next`="https://cnodejs.org/api/v1/topics?page={0}"

-- 不能携带表单中携带的请求参数。

and `config.page.skip-params`="true"

-- 使用 JsonPath 来解析请求中的分页信息。更多信息，请参考: https://github.com/json-path/JsonPath。

and `config.page.values`="$.path1;$.path2"

-- 为每个分页请求设置间隔时间。

and `config.page.interval`="10ms"

-- 为每个分页请求设置设置失败重试次数。

and `config.page.retry`="3"

-- 设置请求页面的数量。

and `config.page.limit`="2"
```

通过json path抽取的值会作为位置参数去重新生成 config.page.next 页。



#### 6. 使用 POST 请求上传文件

```sql
save overwrite command as Rest.`http://lab.mlsql.tech/api/upload_file` where

`config.connect-timeout`="10s"

and `header.content-type`="multipart/form-data"

and `header.Content-Type`="multipart/form-data; boundary=$you_boundary"

and `header.Cookie`="JSESSIONID=$your_jsession_id;"

-- upload file path

and `form.file-path`="/tmp/upload/test_date.csv"

-- upload file name

and `form.file-name`="test_date.csv"

and `config.method`="post"

;
```

我们请求的 byzer-notebook 是需要授权的，我们通过`header.`设置 Jsession 等授权信息。



#### 7. 忽略请求结果异常

对于 http 服务端响应的状态码不是 200 的情况，如果不想报错，可以结合分支加空表的模式：

```sql
-- 这里的 url 是错误的, 因此状态是404。

-- 它将在之后的脚本中抛出异常。

SET ENGINE_URL="https://cnodejs.org/api/v1/topics1"; 

load Rest.`$ENGINE_URL` where

 `config.connect-timeout`="10s"

 and `config.method`="get"

 and `form.page`=''':{select 1 as :b;:b}'''

 and `form.tab`="share"

 and `form.limit`="2"

 and `form.mdrender`="false" 

as raw_cnodejs_articles;



set status= `select status from raw_cnodejs_articles` where type="sql" and mode="runtime";



-- 如果状态不是200，则模拟一个不带数据的新表。

!if ''' :status != 200 '''; 

!then; 

    run command as EmptyTableWithSchema.`` where schema='''st(field(content,binary),field(status,integer))''' as raw_cnodejs_articles;    

!fi;



select status, string(content) as content  

from raw_cnodejs_articles as temp_cnodejs_articles;



run temp_cnodejs_articles as JsonExpandExt.`` 

where inputCol="content" and structColumn="true" 

as cnodejs_articles;



-- 因为这段内容中没有字段数据，应再次模拟表。

-- 从 condejs_articles 中选择 explode(content.data) 作为 article；

-- 从 articles 中选择 article.id, article 作为输出；
```


