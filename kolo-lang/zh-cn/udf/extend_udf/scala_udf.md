# Scala UDF
使用 Scala 语言开发 UDF 时，需要在 `register` 语句中指定如下信息：
- 指定 `lang` 为 Scala
- 指定 `udfType` 为 UDF

**例子**
```
> REGISTER ScriptUDF.`` AS plusFun WHERE
and lang="scala"
and udfType="udf"
and code='''
def apply(a:Double,b:Double)={
a + b
}
''';
```
**使用**
```
> SELECT plusFun(1,2) AS sum;
3
```