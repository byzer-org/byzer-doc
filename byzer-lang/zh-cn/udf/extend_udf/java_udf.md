# Java UDF
使用 Java 语言开发 UDF 时，需要在 `register` 语句中指定如下信息：
- 指定 `lang` 为 Java
- 指定 `udfType` 为 UDF

另外，还需要额外注意几点：
- 传递的代码必须是一个 Java 类，系统默认会寻找 `apply()` 方法做为运行的 UDF 
- 如果需要特殊类名和方法名，需要指定 `className`/`methodName` 进行声明（如例子二）
- 暂时不支持包名

**例子一**
```
REGISTER ScriptUDF.`` AS echoFun WHERE
and lang="java"
and udfType="udf"
and code='''
import java.util.HashMap;
import java.util.Map;
public class Test {
    public Map<String, String> apply(String s) {
      Map m = new HashMap<>();
      m.put(s, s);
      return m;
  }
}
''';
```
**使用：**
```
> SET data='''{"a":"a"}''';
> LOAD jsonStr.`data` AS dataTable;
a
> SELECT funx(a) AS res FROM dataTable AS output;
{ "a": "a" }
```
**例子二**
```
> REGISTER ScriptUDF.`` AS echoFun WHERE 
and lang="java"
and udfType="udf"
and className="Test"
and methodName="test"
and code='''
import java.util.HashMap;
import java.util.Map;
public class Test {
    public Map<String, String> test(String s) {
      Map m = new HashMap<>();
      m.put(s, s);
      return m;
  }
}
''';
```
**使用：**
```
> SET data='''{"a":"a"}''';
> LOAD jsonStr.`data` AS dataTable;
a
> SELECT funx(a) AS res FROM dataTable AS output;
{ "a": "a" }
```