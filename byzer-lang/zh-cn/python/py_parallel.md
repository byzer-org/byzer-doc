# Byzer-python 并行度

你可以直接使用 Byzer-python 对表进行处理，但当数据量比较大时，我们经常会在处理前使用 `!tableRepartition` 对数据进行重新切分。

比如：

```sql
!tableRepartition _ -i simpleDataTemp -num 3 -o simpleData;

!python env "PYTHON_ENV=source activate dev";
!python conf "schema=st(field(_id,string),field(x,double),field(y,double))";
!python conf "dataMode=model";
!python conf "runIn=driver";

run command as Ray.`` where 
inputTable="simpleData"
and outputTable="output_table"
and code='''
# do something here
''';
```

这里，在处理表 simpleDataTemp 之前，我们将其重新划分成3个分区的新表 simpleData， 之后才交给 Python 代码进行处理。这么做主要有以下三个方面原因：

#### 1. 资源

以上面的分区数 3 为例：

- 如果你没有使用 Ray，那么你的集群需要 3+1 个 核，才能让代码正常运行。这意味着如果你的分区过大， 而集群比较繁忙或者资源较少，很可能无法正确运行。


- 如果你使用了 Ray，那么需要保证 Ray 至少有 3 个 CPU 资源。集群需要保证至少 3+3 个资源，否则也可能无法正常的运行任务。

#### 2. 效率

理论上分区越大速度越快。但会受到可用资源的制约。

#### 3. 自动化

尽管你可能设置了 3 个分区，但集群不保证一定按三个分区运行，除非资源足够。所谓足够是指，集群剩余可使用资源核数 > 3 * 2。

假设你的剩余资源为 N，如果你的设置分区数小于 N/2，则会按照你的设置运行；而如果你设置的分区数的 > N/2，那么系统会将分区数调整为 N/2-1。
