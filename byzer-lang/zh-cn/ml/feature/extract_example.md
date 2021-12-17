# FeatureExtractInPlace

FeatureExtractInPlace 实现了提取文本中 `QQ`,`电话`,`邮箱` 等信息的功能，在反垃圾方面十分有用。

### 数据准备

```sql
SET rawData='''
{"content":"请联系 13634282910","predict":"rabbit"}
{"content":"扣扣 527153688@qq.com","predict":"dog"}
{"content":"<html> dddd img.dxycdn.com ffff 527153688@qq.com","predict":"cat"} 
''';
LOAD jsonStr.`rawData` as data;
```

### 抽取

```sql
TRAIN data AS FeatureExtractInPlace.`/tmp/model`
WHERE inputCol="content";

LOAD parquet.`/tmp/model/data` as output;
```

结果如下：

```
content predict phone  noEmoAndSpec  email  qqwechat url pic cleanedDoc blank chinese english number punctuation uninvisible  mostchar  length
请联系 13634282910	rabbit		请联系 13634282910			0	0	请联系 13634282910	6	20	0	73	0	0	2	15
扣扣 527153688@qq.com	dog		扣扣 527153688@qq.com			0	0	扣扣	33	66	0	0	0	0	2	3
<html> dddd img.dxycdn.com ffff 527153688@qq.com	cat		<html> dddd img.dxycdn.com ffff 527153688@qq.com			0	1	dddd ffff	27	0	72	0	0
```

### API 预测

> API 预测的相关原理及示例，详见 [部署算法 API 服务](/byzer-lang/zh-cn/ml/api_service/README.md)

```sql

REGISTER FeatureExtractInPlace.`/tmp/model` as convert;

```

该 ET 比较特殊，会隐式的生成很多 UDF：

- convert_phone
- convert_email
- convert_qqwechat
- convert_url :the number of url
- convert_pic :the number of pic
- convert_blank :blank percentage
- convert_chinese :chinese percentage,
- convert_english :english percentage,
- convert_number  :number percentage,
- convert_punctuation  :punctuation percentage,
- convert_mostchar :mostchar percentage,
- convert_length :text length

用户可以根据需求使用。比如：

```sql

SELECT convert_qqwechat("扣扣 527153688@qq.com ") as features as output;
```

输出结果为：

```
features
true
```

