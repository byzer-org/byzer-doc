# 频数分布 / DescriptiveMetrics

### Background

频数分布 ET 主要是帮助用户从统计的角度计算 count，输入是一张多列二维表，输出是一个两列的二维表，列1为字段名，列2为该字段的值的分布情况，并以 Json String 的方式展示。

起始生效版本：`Byzer-lang V2.3.2`， 该 ET 是集成于 `mlsql-lib` 扩展中，该扩展默认被被集成至 Byzer All-In-One 产品包以及 K8S 镜像中，如果您使用的 Byzer Server 版本，请参考 [Byzer Server 二进制版本安装和部署](byzer-lang/zh-cn/installation/server/binary-installation.md) 一章中安装插件的部分来进行插件的安装

### User Tutorial

该 ET 的输入是一张多个字段的二维表，输出输出两列，包含原始列名（只统计 String 类型的列），还有频数分布的 Json 字符串。

调用方式如下

```sql
-- 假设存在源表数据 table1
select * from table1 as table2;
-- 通过run/train关键字执行，频数分布为精确计算，内部有使用Action算子，会触发spark job提交
run table1 as DescriptiveMetrics.`` as descriptiveMetrics
where metricSize='1000'; -- 支持通过参数metricSize控制条数，默认为100条。metricSize小于等于0是会报错提示参数设置错误。
```

返回结果示例：

| columnName | descriptiveMetrics      |
| ---------- | ----------------------- |
| age        | [{"18":1},{"21":7}]     |
| address    | [{"上海":1},{"广州":7}] |

### 可选参数

- **metricSize**  设置最大返回条数。默认返回频数最高的 100 条。按照列名降序排列。

比如 age 这一列不同的值有行数 1000+，但是 **metricSize** 是100，最后结果表 name 这一列只会显示频数最高的100条。