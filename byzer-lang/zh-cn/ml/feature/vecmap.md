# Map 转化为向量 VecMapInPlace

VecMapInPlace 可以将一个 Map[String,Double] 转化为一个向量。

### 数据准备

假设我们有如下数据：

```sql
set jsonStr='''
{"features":{"a":1.6,"b":1.2},"label":0.0}
{"features":{"a":1.5,"b":0.2},"label":0.0}
{"features":{"a":1.6,"b":1.2},"label":0.0}
{"features":{"a":1.6,"b":7.2},"label":0.0}
''';
load jsonStr.`jsonStr` as data;

register ScriptUDF.`` as convert_st_to_map where
code='''
def apply(row:org.apache.spark.sql.Row) = {
  Map("a"->row.getAs[Double]("a"),"b"->row.getAs[Double]("b"))
}
''';

select convert_st_to_map(features) as f from data as newdata;
```

这里使用了自定义 UDF 去将 Row 转化为 Map，详细了解可以翻看 [动态扩展 UDF](/byzer-lang/zh-cn/transform/udf/extend_udf/README.md)。

### 转化

```sql
train newdata as VecMapInPlace.`/tmp/model`
where inputCol="f";

load VecMapInPlace.`/tmp/model/data` as output;
```

显示结果如下：

```
f
{"type":0,"size":2,"indices":[0,1],"values":[1.6,1.2]}
{"type":0,"size":2,"indices":[0,1],"values":[1.5,0.2]}
{"type":0,"size":2,"indices":[0,1],"values":[1.6,1.2]}
{"type":0,"size":2,"indices":[0,1],"values":[1.6,7.2]}
```
可以看到已经转化为一个二维向量了。

### API 预测

> API 预测的相关原理及示例，详见 [部署算法 API 服务](/byzer-lang/zh-cn/ml/api_service/README.md)

```sql

register VecMapInPlace.`/tmp/model` as convert;

```

通过上面的命令，VecMapInPlace 就会把训练阶段学习到的东西应用起来。
现在，可以使用 `convert` 函数了。

```sql
select convert(map("a",1,"b",0)) as features as output;
```

输出结果为：

```
features
{"type":0,"size":2,"indices":[0,1],"values":[1,0]}
```

通常，我们还需要对向量做平滑或者归一化，请参考对应章节。


