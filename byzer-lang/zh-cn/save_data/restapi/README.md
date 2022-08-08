# 通过 REST API 存储数据

### 保存数据至 REST API 数据源

REST API 既然作为一个数据源，就可以支持读和写，也就是 Byzer 语法中的 `Load / Save` 语义。但出于 REST API 数据源的特殊性，一般情况下都是从 API 进行数据的获取。

对于通过 API 保存数据操作，一般情况下会分为下面两种，无论是哪种方式，都依赖于 API 自身的设计。

#### 1. 通过参数的方式将数据传给 API 

这种方式其实和调用 API 进行数据获取没有什么区别，将需要上传的数据，作为 Request body 中的值，使用 `LOAD` 语句进行 API 调用即可。

对于需要多次调用 API 的情况，可以选择使用 `rest_request` udf

#### 2. 通过数据文件的方式上传给 API 

对于文件上传类的 API，我们可以通过 `SAVE` 语句来进行上传，我们来看一个例子

```sql
> SAVE overwrite command as Rest.`http://xxxxx/api/upload_file` where
`config.connect-timeout`="10s"
and `header.content-type`="multipart/form-data"
and `header.Content-Type`="multipart/form-data; boundary=$you_boundary"
and `header.Cookie`="JSESSIONID=$your_jsession_id;"
-- upload file path
and `form.file-path`="/tmp/upload/test_date.csv"
-- upload file name
and `form.file-name`="test_date.csv"
and `config.method`="post";
```


可以看到 `SAVE` 语句的调用方式是通过
```sql
SAVE overwrite command as Rest.`${API_URL}`
```
的方式进行调用的，`where` 语句条件中是对应的参数信息。

在这个示例中，通过参数 `form.file-path` 以及 `form.file-name` 来指定上传的文件路径和文件名。
