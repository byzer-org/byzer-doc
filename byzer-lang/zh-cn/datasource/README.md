# 在 Byzer 中加载数据源

阅读本章节前，请阅读 [Byzer-Lang 语言向导](/byzer-lang/zh-cn/grammar/outline.md) 以及 [数据加载/Load](/byzer-lang/zh-cn/grammar/load.md)。确保熟悉 Byzer 中数据加载相关的基本概念。

Byzer 的特性是 `Everything is a table`, 它具备加载和存储多种数据源的能力，数据源在 Byzer 的体系中，我们可以将其定义为 **输入**，这些数据源在 Byzer 中都可以抽象成一张带有 Schema 的二维表，供后续进行数据转换或模型训练使用。在 Byzer 中有**内置数据源**以及**外部数据源**两种区别的数据源。

### Byzer 内置数据源

Byzer 内置了一些特殊的数据源，用户可以通过 `SET` 语法，来定义一些数据源变量，这些被定义的对象，可以通过这些内置的数据源加载这个数据源变量作为一个数据源表来进行使用。比如 `jsonStr` 主要是为了加载通过 `SET` 语法定义的 json 字符串变量，将其解析成表；`script` 则是为了将一些脚本加载成表，方便后续引用。

Byzer提供的内置数据源有：
- **jsonStr**
- **csvStr**
- **script**


#### jsonStr
jsonStr 允许用户手动将一个 Json 格式的变量加载为表，我们来看下面的示例：

```sql
> -- define a variable as a json string
> SET rawData=''' 
{"jack":1,"jack2":2}
{"jack":2,"jack2":3}
''';
> -- Load this json string varaible as a table
> LOAD jsonStr.`rawData` AS table1;
```

`jsonStr` 数据源的主要作用是方便用户构造带有嵌套关系的数据结构对象，等同于在编程语言中创建一个数据对象。

#### csvStr

原理和 `jsonStr` 相同，`csvStr` 可以将 Json 格式的变量加载为表，我们来看下面的示例：

```sql
> -- define a variable as a csv table
> SET rawData='''
name,age
zhangsan,1
lisi,2
''';
> -- Load this csv varaible as a table
> LOAD csvStr.`rawData` OPTIONS header="true" AS output;
```

`csvStr` 数据源的主要作用是方便用户构造二维表关系的数据结构对象，方便进行数据测试和调试


#### script

`script` 数据源的作用，是为了将一个文本变量定义成一个可执行的 Byzer 脚本，用于后续在其他宏命令或 ET 中进行引用，我们来看下面的示例：

```sql

> -- 定义了一段python脚本，之后需要通过script load下进行使用
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

通过 `script` 将一段脚本内容定义成变量后，将此变量进行 `load` 之后，该脚本就可以作为一个表的变量，方便被后面的语句引用。
这部分可以参照 [Byzer 的 UDF 功能](/byzer-lang/zh-cn/udf/README.md) 理解。


### 加载外部数据源

Byzer 支持的外部数据源类型如下：
- [JDBC 数据源](/byzer-lang/zh-cn/datasource/jdbc.md)
- [数据仓库/湖](/byzer-lang/zh-cn/datahouse/README.md)
- [文件数据源](/byzer-lang/zh-cn/datasource/file.md)
- [REST API](/byzer-lang/zh-cn/datasource/restapi.md)
- [流式数据源](../../../byzer-lang/zh-cn/datasource/kafka.md)
- [其他](../../../byzer-lang/zh-cn/datasource/other.md)

本章节我们会给出这些数据源的说明和使用示例。

