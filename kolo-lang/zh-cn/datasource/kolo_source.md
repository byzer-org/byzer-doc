# 内置数据源

Byzer 内置了一些特殊的数据源，这些数据源读取的对象是在 Byzer 中经过 `SET` 的变量。

比如 `jsonStr` 主要是为了加载通过 `SET` 语法得到的 json 字符串，后续解析成表。
`script` 则是为了将一些脚本加载成表，方便后续引用。

Byzer提供的内置数据源有：
- jsonStr
- csvStr
- script


## jsonStr
jsonStr 可以将 Csv 格式的变量加载为表。

```sql
> SET rawData=''' 
{"jack":1,"jack2":2}
{"jack":2,"jack2":3}
''';

> LOAD jsonStr.`rawData` AS table1;
```

`jsonStr` 的存在使得调试程序时可以方便的构造数据。当然也可以作为数据模版进行使用。

## csvStr

同`jsonStr`，`csvStr` 可以将 Json 格式的变量加载为表。

```sql
> SET rawData='''
name,age
zhangsan,1
lisi,2
''';
> LOAD csvStr.`rawData` OPTIONS header="true" AS output;
```

## script

`script` 使用方式和 `jsonStr` 类似，我们来看一个例子：

```sql

-- 定义了一段python脚本，之后需要通过script load下进行使用

> SET python_script='''
import os
import warnings
import sys

import mlsql

if __name__ == "__main__":
    warnings.filterwarnings("ignore")

    tempDataLocalPath = mlsql.internal_system_param["tempDataLocalPath"]

    isp = mlsql.params()["internalSystemParam"]
    tempModelLocalPath = isp["tempModelLocalPath"]
    if not os.path.exists(tempModelLocalPath):
        os.makedirs(tempModelLocalPath)
    with open(tempModelLocalPath + "/result.txt", "w") as f:
        f.write("jack")
''';

> LOAD script.`python_script` as python_script;

> RUN testData AS PythonParallelExt.`${modelPath}`
WHERE scripts="python_script"
and entryPoint="python_script"
and condaFile="...."; 
```

只有通过 `script` 进行 `load` 之后才能方便的被后面的语句引用。
这部分可以参照 [Byzer 的 UDF 功能](/byzer-lang/zh-cn/udf/README.md) 理解。


