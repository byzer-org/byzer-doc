# Python UDF
使用 Python 语言开发 UDF 时，需要在 `register` 语句中指定如下信息：
- 指定 `lang` 为 Python
- 指定 `udfType` 为 UDF

对于 Python UDF，特别说明以下几点：

1. Kolo 支持 Python 版本为 `2.7.1`
2. Python 不支持任何 native 库，比如 `numpy`.
3. Python 必要使用 `dataType` 参数指定返回值的类型（例子1）
   目前我们支持的 Python UDF 返回类型只能是如下类型或者他们的组合 
   - string
   - float
   - double 
   - integer
   - short
   - date
   - binary
   - map
   - array
4. 为了弥补 Python UDF 的不足，Kolo 提供了专门的交互式 Python 语法以及大规模数据处理的 Python 语法。在 Python 专门章节 我们会提供更详细的介绍。

因此，我们建议对于 Python 尽可能只做简单的文本解析处理，以及使用原生自带的库。

**例子**
```
> REGISTER ScriptUDF.`` AS echoFun WHERE
and lang="python"
and dataType="map(string,string)"
and code='''
def apply(self,m):
    return m
 ''';
```
**使用**
```
> SELECT echoFun(map("a","b")) AS res;
{ "a": "b" }
```