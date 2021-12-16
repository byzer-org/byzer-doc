# Scala UDAF
使用 Scala 语言开发 UDAF 时，需要在 `register` 语句中指定如下信息：
- 指定 `lang` 为 Scala
- 指定 `udfType` 为 UDAF

**例子**
```
> SET plusFun='''
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

> LOAD script.`plusFun` AS scriptTable;

> REGISTER ScriptUDF.`scriptTable` AS plusFun options
className="SumAggregation"
and udfType="udaf";
```
**使用**
```
> SET data='''
{"a":1}
{"a":1}
{"a":1}
{"a":1}
''';
> LOAD jsonStr.`data` AS dataTable;

> SELECT a,plusFun(a) AS res FROM dataTable GROUP BY a AS output;
| a | res |
|===|=====|
| 1 |  4  |
```