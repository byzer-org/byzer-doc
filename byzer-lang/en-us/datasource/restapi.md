# RestApi

Byzer supports RestApi as a data source and registers the return value as a table.

RestApi supports a retry mechanism and multiple requests with fields in the return value, and combines all return values ​​into a table.

Example:
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

In this example, firstly, we obtain 3 parameters by executing Byzer's syntax when the SET syntax is running. For more information, see [Set syntax](/byzer-lang/en-us/grammar/set.md).

In the load statement, the data source marked by `Rest` keyword is RestApi. In quotation marks you can fill in the access URL or reference set variables.

Use the `where` clause to set parameters in the load statement.
`config.connect-timeout` means to set the timeout time to 10s,
`config.method` sets the request method to POST,`header.content-type` sets the content format of the request,
`body` sets the body of the post request,
Finally register the return value as a table named token_1.

## Parameter settings

There are three types of parameters:
- config: set rest request information such as `method`,`timeout`, etc.
- header: set the header
- body/form: set request parameters which vary with `method` or `content-type`

**Basic parameter list**

| Parameter | Is it necessary | Instruction |
|---|-------|---|
| config.method | Necessary | Method of rest request, optional GET/POST/PUT |
| config.socket-timeout | not necessary | Socket connection time, fill in the time with units such as 10s |
| config.connect-timeout | not necessary | Connection timeout, fill in the time with units such as 10s |
| header.Content-Type | not necessary | When method is POST, the default is application/x-www-form-urlencoded; when method is GET, the default is application/json |
| header.${user_define} | not necessary | In this way, you can customize header |
| form.${user_define} | not necessary | When Content-Type is application/x-www-form-urlencoded, set parameters in this way |
| body | not necessary | When Content-Type is application/json, set the request body in this way |

> **Note:** All parameter values ​​must be character strings. It means that they must be enclosed in `""` or `'''`. Parameter values ​​can be variables obtained by `SET`

## Advanced parameter settings

Byzer supports multiple requests by fetching the fields in the return value and combine all the return values ​​into a table.
Example:

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

In this example, we first set the token obtained in the previous example as a variable through the `SET` syntax. [SparkSQL Build-in Function](https://spark.apache.org/docs/latest/api/sql/) is used here.
Next we make multiple requests using the `load` syntax and `Rest` tool.
The parameters used are explained in detail below:

**`config.page.values`**

is the key information of next page in the return structure and uses [JsonPath syntax](https://github.com/json-path/JsonPath).
You can specify multiple key information and use them in`config.page.next`.

**`config.page.next`**

Indicates the url of the next request. You can use {0},{1}... {n} to represent some information obtained by `config.page.values`, and write it directly into the request string, like:
```sql
config.page.next="http://www.example.com/rest/{0}/deleted?projects={1}"
```
If the `$.nextPage` path is the request link, it can be written directly like the example:
```sql
config.page.next="{0}"
```

**`config.page.interval`**

Indicates the request interval for multiple requests. Some SAAS services have limitation for requests. For example, only 100 requests are allowed within 120s. In this case, you can set this parameter to `1200ms` or `1.2s`.

The default value is `10ms`.

**`config.page.limit`**

Indicates the number of requests or pages, the default is `1` times.



## return value

The load statement sets the return value of the request to a table. There are two columns:
- content: return body encoded by base64
- status: http status code

As follows:

| content | status |
|--------|--------|
| (base64 encode content) | (http status) |

If there are multiple requests, there will be multiple rows in the returned table and each row represents the result of one request.
You can use [SparkSQL Build-in Function](https://spark.apache.org/docs/latest/api/sql/) or UDFs to perform aggregations and other operations on them.