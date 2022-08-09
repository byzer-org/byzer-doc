# 模式分布 / PatternDistribution

### Background

根据业务方具体的业务场景回流的需求，增加字符串模式分布统计的算法 ET。该 ET 主要是对标 SAS 系统的模式统计功能，总结字符串类型列的文本模式，从统计学的角度观察数据的模式分布，从而更好的结合数据离散化的加工。

注：该 ET 属于 Byzer 扩展，代码实现见：[SQLDataSummary.scala](https://github.com/byzer-org/byzer-extension/blob/master/mlsql-mllib/src/main/java/tech/mlsql/plugins/mllib/ets/fe/SQLPatternDistribution.scala)，
该 ET 默认被集成至 Byzer All-In-One 产品包以及 K8S 镜像中，起始生效版本为 `byzer v2.3.2`。
如果您使用的是 Byzer Server 版本，请参考[Byzer Server 部署](/byzer-lang/zh-cn/installation/server/binary-installation.md) 章节中安装 Byzer Extension 的一节

### User Tutorial

该ET 该 ET 的输入是一张多个字段的二维表，输出两列，包含原始列名（只统计 String 类型的列），还有模式分布的 Json 字符串。

调用方式如下

```SQL
set abc='''
{"name": "elena", "age": 57, "phone": 15552231521, "income": 433000, "label": 0}
{"name": "candy", "age": 67, "phone": 15552231521, "income": 1200, "label": 0}
{"name": "bob", "age": 57, "phone": 15252211521, "income": 89000, "label": 0}
{"name": "candy", "age": 25, "phone": 15552211522, "income": 36000, "label": 1}
{"name": "candy", "age": 31, "phone": 15552211521, "income": 300000, "label": 1}
{"name": "finn", "age": 23, "phone": 15552211521, "income": 238000, "label": 1}
''';

load jsonStr.`abc` as table1;
select name, age, income from table1 as table2;
run table2 as PatternDistribution.`` as pd_table;
```

#### 可选参数

- **limit**  设置最多的模式行，如果模式总数不超过patternLimit的值，默认为100. 
比如 name 这一列的模式有 105 个模式，但是 patternLimit 是100，
最后结果表 name 这一列只会显示 100 个模式

调用方式如下

```SQL
run table2 as PatternDistribution.`` where limit=1000 as pd_table;
```

- **excludeEmptyVal** 设置是否过滤空值，ture 或者 false，默认 true

比如 name 这一列有包含空值或者空字符串，如果 excludeEmptyVal 为 true，那么模式统计不会考虑空值，反之亦然

调用方式如下
```SQL
run table2 as PatternDistribution.`` where excludeEmptyVal="true" as pd_table;
```

- **patternLimit** 指- 设置最长的模式长度，默认为 1000。
比如 name 这一列的某一个模式长度为 2000， 模式的结果里值展示 substr(0, 1000) 的子串
调用方式如下

```SQL
run table2 as PatternDistribution.`` where patternLimit=1000 as pd_table;
```