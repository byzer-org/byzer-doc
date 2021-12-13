# 动态创建UDF/UDAF

Kolo 支持使用 Python、Java、Scala 编写UDF/UDAF。
无需打包或重启，只需运行注册 UDF 的 Kolo 代码，就可以即时生效。
极大的方便用户扩展 Kolo 的功能。

### UDF注册

Kolo 提供 `register` 语法注册 UDF。你可以用以下两种方式使用它。

#### 方法一

先将脚本注册为虚拟表，再将表注册为UDF。

下面是一个使用 scala 语言编写 UDF 并注册的例子：
```
-- script
> SET plusFun='''
def apply(a:Double,b:Double)={
   a + b
}
''';

-- register as a table
> LOAD script.`plusFun` AS scriptTable;

-- register as UDF
> REGISTER ScriptUDF.`scriptTable` AS plusFun OPTIONS lang = "scala";
```

#### 方法二

Kolo 支持在一个语句中完成 UDF 的注册的所有步骤。

在这种方式中，我们必须手动指定脚本的编写语言，以及 UDF 的种类。文末有我们支持的语言以及 UDF 列表。

下面是一个使用 scala 语言编写并注册的例子。
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
---
#### 总结

**适用范围**

`方法一`方便做代码分割，UDF 申明可以放在单独文件，注册动作可以放在另外的文件，通过 `include` 来完成整合。

`方法二`相较于`方法一`更为简洁明了，适合数量较少的 UDF 注册。

**参数设置**

`方法一`使用 OPTIONS 关键字连接参数，`方法二`使用 WHERE 关键字连接参数。

**目前支持的参数有：**
- lang: Scala/Java/Python
- udfType: UDF/UDAF
- code: UDF 代码
- className: code中自定义类名（仅Java）
- methodName: code中自定义函数名

---

### UDF使用

无论使用哪种方式注册，你都可以开箱即用的使用注册过的 UDF。下面是一个使用上面注册过的 UDF 的例子。

```
> SELECT plusFun(1,2) AS sum;
3
```

### 支持的语言/UDF种类

- Scala：UDF/UDAF
- Java：UDF     
- Python：UDF     
