# 数据剖析 / DataSummary

### Background

在业务真实的数据EDA需求场景背景下，提升和丰富 DataSummary 对数据集的全局统计和剖析的能力。
具体地，DataSummary ET 提供给用户多种功能选项，包括精确计算开关操作（ 提供用户小数据量情况下的精确计算分位数，精确计算中位数）以及增加过滤空值和空字符串等功能。

> 该 ET 属于 Byzer 扩展，代码实现见：[SQLDataSummary.scala](https://github.com/byzer-org/byzer-extension/blob/master/mlsql-mllib/src/main/java/tech/mlsql/plugins/mllib/ets/fe/SQLDataSummary.scala)

### User Tutorial

该ET 的输入是一张多个字段的二维表，输出表是多个指标为列名的二维宽表

调用方式如下

```sql
-- 假设存在源表数据 table1
select * from table1 as table2;
-- 执行 DataSummary 完成源表数据的数据剖析功能
run table2 as DataSummary.`` as summaryTable;
-- 由于 v2.0 的 DataSummary 展示的剖析指标相对较多，用户可以根据需要选择指标，比如
run table2 as DataSummary.`` as summaryTable
where metrics='mean, median, 75%' -- 选取剖析结果的均值，数据类型，众数，中位数还有3/4分位数作为指标输出
and roundAt='2' -- 剖析数据保留 2 位小数
and approxSwitch="false"; -- 是否精确计算分位数
```

#### 可选参数

- **metrics**  执行要展示的统计值，默认展示所有统计值

比如，用户只想要显示均值，数据类型，众数，还有 3/4 位数, 可以通过如下 SQL 调用

调用方式如下

```sql
run table2 as DataSummary.`` as summaryTable
where metrics='mean, datatype, mode, median, 75%'
```

- 参数 **metrics** 可以填的值如下 `mode`, `uniqueValueRatio`, `nullValueRatio`, `blankValueRatio`, `mean`, `nonNullCount`, `standardDeviation`, `standardError`, `max`, `min`, `maximumLength`, `minimumLength`, `primaryKeyCandidate`, `dataLength`, `dataType`, `%25`, `median`, `%75`

- 参数 **roundAt** 指标统计保留位数，默认保留 2 位小数

比如，用户的统计指标，需要展示 4 位小数，可以通过如下调用

```sql
run table2 as DataSummary.`` as summaryTable
where rountAt="4";
```

- 参数 **approxCountDistinct** 指定是否打开近似计算，默认为 false。spark 为了解决大数据量的处理效率， count 计算提供了 approx_count_distinct 功能。如果打开 approxCountDistinct DataSummary ET 会开启近似计算，从而提高计算效率，
  调用方式如下
```sql
run table2 as DataSummary.`` as summaryTable
where approxCountDistinct="true"; 
-- and threshold=0.98
--当打开approxCountDistinct开关，DataSummary会根据计算的 uniqueValueRatio 与 threshold (默认值为0.9) 做比较，大于 threshold 会再做一次精准计算
-- threshold 
```

- 参数 **relativeError** 指定计算分位数（ median/50%, 25%, 75%）的误差率，默认值是 0.01，误差率设置的值越高，分位数指标计算的速度越快，性能也越好。误差率设置为 0.0 的时候，是精准计算，耗时较长。
```sql
run table2 as DataSummary.`` as summaryTable
where relativeError="0.05";
```

#### Details

DataSummary ET 是一个数据 EDA 工具，完成全局数据剖析指标展示，所包含的指标包括：

1. 列名 columnName
2. 数据类型 dataType
3. 唯一值比例 （数值类型和非数值类型都支持） uniqueValueRatio
4. 空（空值的比例，数值类型和非数值类型都支持）nullValueRatio
5. 空白（空字符串的比例，数值类型和非数值类型都支持）blankValueRatio
6. 均值  (仅数值类型, 非数值类型展示为空) mean
7. 中位数 (仅数值类型, 非数值类型展示为 0.0) median
8. 众数 (数值类型和非数值类型都支持) mode
9. 标准差 (仅数值类型非数值类型展示为空)，standardDeviation 
10. 标准误差（仅计算数值类型，非数值类型的标准误差展示为空) standardError
11. 最小值 (数值类型和非数值类型都支持) max
12. 最大值 (数值类型和非数值类型都支持) min
13. 最小长度 （该列中数据的最小长度，数值类型和非数值类型都支持）maximumLength
14. 最大长度（该列中数据的最小长度，数值类型和非数值类型都支持）minimumLength
15. 序号位置（字段在table中的位置/顺序，数值类型和非数值类型都支持）ordinalPosition
16. 主健候选者（是/否，唯一值的比例为100%的字段，则“是”，数值类型和非数值类型都支持 ）primaryKeyCandidate
17. 非空计数 （不是空值的数据量，数值类型和非数值类型都支持）nonNullCount
18. 四分位数 -- (仅数值类型, 非数值类型展示为 0.0) %25 
19. 四分三位数 -- (仅数值类型, 非数值类型展示为 0.0) %75

#### 性能分析 
详情见 [DataSummaryET 性能分析](/byzer-lang/zh-cn/appendix/performance_test.md)


