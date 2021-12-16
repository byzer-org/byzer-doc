# 注册函数，模型/Register

Register 句式在 Byzer-lang 中主要可以完成三类工作：

1. 动态注册 Java/Scala 写的 UDF/UDAF 函数
2. 将内置或者 Python 模型注册成 UDF 函数
3. 在流式计算中，注册 wartermark/window

## 注册 SQL 函数

在 SQL 中，最强大的莫过于函数了。Byzer-lang 支持动态创建 UDF/UDAF 函数。

示例代码：

```ruby
register ScriptUDF.`` as plusFun where
and lang="scala"
and udfType="udf"
code='''
def apply(a:Double,b:Double)={
   a + b
}
''';
```

上面代码的含义是，使用 ET ScriptUDF 注册一个函数叫 `plusFun`，这个函数使用 Scala 语言，函数的类型是 UDF,对应的实现代码在 code 参数里。

在 Byzer-lang 中， 执行完上面代码后，用户可以直接在 `select` 语句中使用 `plusFun` 函数：

```sql
-- create a data table.
 set data='''
 {"a":1}
 {"a":1}
 {"a":1}
 {"a":1}
 ''';
 load jsonStr.`data` as dataTable;

 -- using echoFun in SQL.
 select plusFun(1,2) as res from dataTable as output;
```

其中：

1. lang 支持 java/scala
2. udfType 支持 udf/udaf 

### 通过变量持有代码片段

代码片段也可以使用变量持有，然后在 ScriptUDF 中引用：

```sql
set plusFun='''

def apply(a:Double,b:Double)={
   a + b
}

''';

-- load script as a table, every thing in mlsql should be table which 
-- can be process more convenient.
load script.`plusFun` as scriptTable;

-- register `apply` as UDF named `plusFun` 
register ScriptUDF.`scriptTable` as plusFun
;

-- create a data table.
set data='''
{"a":1}
{"a":1}
{"a":1}
{"a":1}
''';
load jsonStr.`data` as dataTable;

-- using echoFun in SQL.
select plusFun(1,2) as res from dataTable as output;
```

一个变量可以持有多个方法，然后分别进行注册：

```sql
set plusFun='''
class A {

    def apply(a:Double,b:Double)={
       a + b
    }

    def hello(a:String)={
       "hello: "+a
    }
}
''';


load script.`plusFun` as scriptTable;
register ScriptUDF.`scriptTable` as plusFun where methodName="apply" and className="A";
register ScriptUDF.`scriptTable` as helloFun options
methodName="hello"  and className="A";

-- using echoFun in SQL.
select plusFun(1,2) as plus, helloFun("jack") as jack as output;
```

### Scala UDAF示例

```ruby
set plusFun='''
import org.apache.spark.sql.expressions.{MutableAggregationBuffer, UserDefinedAggregateFunction}
import org.apache.spark.sql.types._
import org.apache.spark.sql.Row
class SumAggregation extends UserDefinedAggregateFunction with Serializable{
    def inputSchema: StructType = new StructType().add("a", LongType)
    def bufferSchema: StructType =  new StructType().add("total", LongType)
    def dataType: DataType = LongType
    def deterministic: Boolean = true
    def initialize(buffer: MutableAggregationBuffer): Unit = {
      buffer.update(0, 0l)
    }
    def update(buffer: MutableAggregationBuffer, input: Row): Unit = {
      val sum   = buffer.getLong(0)
      val newitem = input.getLong(0)
      buffer.update(0, sum + newitem)
    }
    def merge(buffer1: MutableAggregationBuffer, buffer2: Row): Unit = {
      buffer1.update(0, buffer1.getLong(0) + buffer2.getLong(0))
    }
    def evaluate(buffer: Row): Any = {
      buffer.getLong(0)
    }
}
''';


--加载脚本
load script.`plusFun` as scriptTable;
--注册为UDF函数 名称为plusFun
register ScriptUDF.`scriptTable` as plusFun options
className="SumAggregation"
and udfType="udaf"
;

set data='''
{"a":1}
{"a":1}
{"a":1}
{"a":1}
''';
load jsonStr.`data` as dataTable;

-- 使用plusFun
select a,plusFun(a) as res from dataTable group by a as output;
```

### Java 语言 UDF 示例


```sql
set echoFun='''
import java.util.HashMap;
import java.util.Map;
public class UDF {
  public Map<String, Integer[]> apply(String s) {
    Map<String, Integer[]> m = new HashMap<>();
    Integer[] arr = {1};
    m.put(s, arr);
    return m;
  }
}
''';

load script.`echoFun` as scriptTable;

register ScriptUDF.`scriptTable` as funx
options lang="java"
;

-- create a data table.
set data='''
{"a":"a"}
''';
load jsonStr.`data` as dataTable;

select funx(a) as res from dataTable as output;
```

由于 Java 语言的特殊性，有如下几点注意事项：

> 1. 传递的代码必须是一个 Java 类，并且默认系统会寻找 `UDF.apply()` 做为运行的 udf，如果需要特殊类名和方法名，需要在 `register` 时声明必要的 `options`，参考例子2。
> 2. 不支持包名( package 声明)

例子2：

```sql
set echoFun='''
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

load script.`echoFun` as scriptTable;

register ScriptUDF.`scriptTable` as funx
options lang="java"
and className = "Test"
and methodName = "test"
;

-- create a data table.
set data='''
{"a":"a"}
''';
load jsonStr.`data` as dataTable;

select funx(a) as res from dataTable as output;
```

## 注册模型

具体使用方式如下：

```sql
register  RandomForest.`/tmp/rf` as rf_predict;

select rf_predict(features) as predict_label from trainData
as output;
```

register语句的含义是： 将 `/tmp/rf ` 中的 RandomForest 模型注册成一个函数，函数名叫 rf_predict.

register 后面也能接 where/options 子句：

```sql
register  RandomForest.`/tmp/rf` as rf_predict
options algIndex="0"
-- and autoSelectByMetric="f1" 
;
```

如果训练时同时训练了多个模型的话：

1. algIndex 可以让用户手动指定选择哪个模型
2. autoSelectByMetric 则可以通过一些指标，让系统自动选择一个模型。内置算法可选的指标有： f1|weightedPrecision|weightedRecall|accuracy。

如果两个参数都没有指定话的，默认会使用 `f1` 指标。


## 流式程序中注册 Watermark

在流式计算中，有 wartermark 以及 window 的概念。我们可以使用 `Register` 句式来完成这个需求：

```sql
-- register watermark for table1
register WaterMarkInPlace.`table1` as tmp1
options eventTimeCol="ts"
and delayThreshold="10 seconds";
```
