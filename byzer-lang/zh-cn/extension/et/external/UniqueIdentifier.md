# UniqueIdentifier

## Background

需求来源于生产环境真实（某银行数据挖掘流程中的数据EDA需求）需求，需要对表生成一列全局唯一的值，该唯一值列为数字顺序递增，不会出现数据乱序，可以选择替换现有列或者创建新列。

## User Tutorial

通过Byzer ET的方式执行唯一标识符计算，可以设置可选参数来控制替换现有列或者创建新列，如果是创建新列，需要指定一个列名，默认为Unique_ID，新的列会插入到表的第一列前面；如果选择替换现有列，则会在原有列的位置，进行数据覆盖。

**唯一值生成规则**：唯一值为从1开始的自增ID，（sas规则：自增ID+01）

调用方式如下

```SQL
-- 假设存在源表数据 table1
select * from table1 as table2;
-- 调用唯一标识符计算的ET，返回值包括原始列名和频数分布的json数据
run table2 as UniqueIdentifier.`` where source="replace" and columnName="income" as uniqueIdentifier;
```

返回结果示例：

| Unique_ID | havana_id | a    | b    |
| --------- | --------- | ---- | ---- |
| 1         | 1         | aaa  | bbb  |
| 2         | 2         | aaa  | bbb  |
| 3         | 3         | aaa  | bbb  |
| 4         | 1         | aaa  | bbb  |
| 5         | 2         | aaa  | bbb  |
| 6         | 3         | aaa  | bbb  |

### 可选参数

- **source**  设置替换现有列或者创建新列，new 或 replace，默认值 new。

- **columnName**  设置唯一值列的列名，默认为 Unique_ID，如果输入的列存在，会报错终止操作。