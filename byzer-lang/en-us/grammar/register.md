# Register: Functions and Model

In Byzer-Lang, the `register` statement can complete three types of work:

1. Dynamically register UDF/UDAF function written in Java/Scala.
2. Register built-in models or Python models as UDF function.
3. In streaming computing, register watermark/window.

## Register SQL functions

The most powerful feature of SQL is its functions. Byzer-Lang supports dynamic creation of UDF/UDAF functions.

Sample code:

```ruby
register ScriptUDF.`` as plusFun where
lang="scala"
and udfType="udf"
and code='''
def apply(a:Double,b:Double)={
   a + b
}
''';
```

The meaning of the above code is to register a function called `plusFun` with ET ScriptUDF. This function uses the Scala language with function type of UDF, and the corresponding implementation code is in the code parameter.

In Byzer-Lang, after executing the above code, users can use the `plusFun` function directly in the `select` statement:

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

Note:

1. Byzer-Lang supports java/scala.
2. udfType supports udf/udaf.

### Quote code segments via variables

You can also quote the code segments in ScriptUDF via variables:

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

A variable can refer to multiple methods, and then register separately:

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

### Scala UDAF sample

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


--load script
load script.`plusFun` as scriptTable;
--Register as a UDF function with the name plusFun
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

-- use plusFun
select a,plusFun(a) as res from dataTable group by a as output;
```

### Java UDF Example


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

Due to the feature of the Java language, the following points should be noted:

> 1. The passed code must be of Java class, and by default,  the system will look for `UDF.apply()` as the running udf. If you need special class names and method names, you need to declare necessary `options` in `register`. You can refer to the below example for more information.
> 2. Package names (package declaration) are not supported.

Example 2:

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

## Register the model

The specific code is as follows:

```sql
register  RandomForest.`/tmp/rf` as rf_predict;

select rf_predict(features) as predict_label from trainData
as output;
```

The meaning of the register statement is to register the RandomForest model in `/tmp/rf ` as a function, named as `rf_predict`.

The register statement can also be followed by `where/options` clauses:

```sql
register  RandomForest.`/tmp/rf` as rf_predict
options algIndex="0"
-- and autoSelectByMetric="f1"
;
```

If multiple models are trained at the same time:

1. `algIndex` allows users to manually specify which model to select
2. `autoSelectByMetric` allows the system to automatically select a model via some indexes. The available indexes of the built-in algorithm are: f1|weightedPrecision|weightedRecall|accuracy.

If neither parameter is specified, the `f1` index will be used by default.


## Register Watermark in streaming program

Watermark and window are concepts of stream computing. We can use the `Register` statement to meet this requirement:

```sql
-- register watermark for table1
register WaterMarkInPlace.`table1` as tmp1
options eventTimeCol="ts"
and delayThreshold="10 seconds";
```
