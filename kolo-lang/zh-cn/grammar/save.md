## 保存数据/save

save语法类似传统SQL中的insert语法。但同load语法一样，Kolo-lang是要面向各种数据源的。insert语法无法很好的满足该诉求，
同时insert语法过于繁琐，所以Kolo-lang提供了新的save语法专门应对数据存储。

### 基本语法

```sql
set rawData=''' 
{"jack":1,"jack2":2}
{"jack":2,"jack2":3}
''';
load jsonStr.`rawData` as table1;
save overwrite table1 as json.`/tmp/jack`;
```

最后一句就是save句式了。 

怎么理解这个句式呢？ 将table1覆盖保存，使用json格式，保存位置为 `/tmp/jack`。 还是比较易于理解的吧。通常，save语句里的数据源或者格式和load是保持一致的，配置参数也类似。但有部分数据源只支持save,有部分只支持load。典型的比如 jsonStr,他就 只支持load,不支持save。

save语句也支持where/options条件子句。比如，我希望保存的时候，将数据按切分成十分来保存，就可以按下面的方式写：

```sql
save overwrite table1 as json.`/tmp/jack` where fileNum="10";
```

Save支持四种存储方式：

1. overwrite
2. append
3. ignore
4. errorIfExists

save 也支持connect 语句的引用。

比如：

```sql

select 1 as a as tmp_article_table

connect jdbc where
url="jdbc:mysql://127.0.0.1:3306/wow?characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&tinyInt1isBit=false"
and driver="com.mysql.jdbc.Driver"
and user="xxxxx"
and password="xxxxx"
as db_1;

save append tmp_article_table as jdbc.`db_1.crawler_table`;
```