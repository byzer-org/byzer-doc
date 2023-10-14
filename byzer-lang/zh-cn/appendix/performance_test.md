# 数据剖析 / DataSummary 性能分析

## 说明
本次性能和精度的对比主要是用7052386条数据作为benchmark，分别做 0.01, 0.1, 1的比例做采样, 然后分别对数据进行指标计算，测量计算的耗时。

- **The elapsed time for normal metrics** 测量的是计算maximumLength, minimumLength, uniqueValueRatio,median,mode,primaryKeyCandidate,nullValueRatio,blankValueRatio,mean,standardDeviation,standardError,max,min 指标的时间
- **The elapsed time for percentile metrics**  测量的是计算 %25, median, 75% 分位数指标的时间，本次测试结果用的是 median 的计算时间。
- **The elapsed time for mode metrics** 测量的是众数的计算时间

计算时间提升比例，（精准计算耗时-近似计算耗时）/ 精准计算耗时

计算时间提升倍数，  精准计算耗时/近似计算耗时

误差计算：abs( 精准计算结果-近似计算结果 )/ 精准计算结果

由于误差计算只可能出现在 uniqueValueRatio 和 primaryKeyCandidate 两个指标，因此本次分析结果只显示这两个指标的结果，以方便对比。

## 数据量 7w

### 精准计算

The elapsed time for normal metrics is : 5730ms => 5.7s

The elapsed time for percentile metrics is: 2130ms => 2.13s

The elapsed time for mode metric is: 1880ms => 1.88s

|ColName|uniqueValue Ratio| primaryKeyCandidate| median|
|-|-|-|-|
|id|1.0| 1| 3505467.0|
|sno|0.0| 0| 35.0|
|name|0.0| 0| 0.0|
|sex|0.0| 0| 1.0|
|cno|0.0| 0| 7.0|
|score|0.0| 0| 89.0|

### 近似计算

The elapsed time for normal metrics is : 1704ms=> 1.7s 提升70.2%, 快3.35倍

The elapsed time for percentile metrics is: 480ms => 0.48s 提升77.5%，快4.44倍

The elapsed time for mode metric is: 773ms =>0.773s


|ColName|uniqueValue Ratio| primaryKeyCandidate| median|
|-|-|-|-|
|id|1.01| 1| 3458945.0|
|sno|0.0| 0| 35.0|
|name|0.0| 0| 0.0|
|sex|0.0| 0| 1.0|
|cno|0.0| 0| 7.0|
|score|0.0| 0| 89.0|

## 数据量70w

### 精准计算

The elapsed time for normal metrics is : 14866ms. => 14.8s

The elapsed time for percentile metrics is: 7704 ms => 7.7s

The elapsed time for mode metric is: 2261ms => 2.26s

|ColName|uniqueValue Ratio| primaryKeyCandidate| median|
|-|-|-|-|
|id|1.01| 0| 3490862.0|
|sno|0.0| 0| 35.0|
|name|0.0| 0| 0.0|
|sex|0.0| 0| 1.0|
|cno|0.0| 0| 7.0|
|score|0.0| 0| 89.0|

### 近似计算

The elapsed time for normal metrics is : 1884ms => 1.8s  提升87.84%，快8.2倍

The elapsed time for percentile metrics is: 785ms=>0.785s 提升89.8%，快 9.8 倍

The elapsed time for mode metric is: 1063ms=>1.063s 

|ColName|uniqueValue Ratio| primaryKeyCandidate| median|
|-|-|-|-|
|id|0.89| 0| 3490862.0|
|sno|0.0| 0| 35.0|
|name|0.0| 0| 0.0|
|sex|0.0| 0| 1.0|
|cno|0.0| 0| 7.0|
|score|0.0| 0| 89.0|

## 数据量 700w

### 精准计算

The elapsed time for normal metrics is : 27s

The elapsed time for percentile metrics is: 58s

The elapsed time for mode metric is: 2s

|ColName|uniqueValue Ratio| primaryKeyCandidate| median|
|-|-|-|-|
|id|1.0| 1| 3525174 |
|sno|0.0| 0| 35.0|
|name|0.0| 0| 0.0|
|sex|0.0| 0| 1.0|
|cno|0.0| 0| 7.0|
|score|0.0| 0| 89.0|


###  近似计算

The elapsed time for normal metrics is : 2s  提升92.6%，快13倍

The elapsed time for percentile metrics is: 1s 提升98.3%，快58倍

The elapsed time for mode metric is: 1s

|ColName|uniqueValue Ratio| primaryKeyCandidate| median|
|-|-|-|-|
|id|0.94| 0.0| 352422.0 |
|sno|0.0| 0| 35.0|
|name|0.0| 0| 0.0|
|sex|0.0| 0| 1.0|
|cno|0.0| 0| 7.0|
|score|0.0| 0| 89.0|

 ```
 P.S. 
 
 Median指标的精确度计算是计算将｜精确计算的位置点-近似计算的位置点｜/ 精确计算的位置点。
分位数计算主要是在数据排序后进行的分位点的计算，在近似计算的情况下，对于分布比较分散的指标（或者唯一值比例比较高的）而言，近似计算的误差比较容易看出来。
同理，对于分布比较均匀的指标，误差率会降低。
 ```
