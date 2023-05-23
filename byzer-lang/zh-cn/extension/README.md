# 插件日常操作

Byzer-lang 支持插件安装，删除，获取列表等。安装和删除插件的语法如下

`!plugin <pluginType> <operation> [-] "<pluginName>";`

- pluginType 表示插件类型，目前有 `app` `ds` `et` 三种。
- operation  表示操作类型，`add` `remove`。
- pluginName 表示插件名称。
- 安装插件时，请在插件名称前加横杠，并以空格分割。删除时，无需空格。

安装插件前，请配置 Byzer-lang 数据湖目录 `streaming.datalake.path`，支持本地文件系统，HDFS，对象存储。
Byzer-lang 下载插件至数据湖目录，并热加载之。获取列表语法如下：

`!plugin list [pluginType];`

若不指定插件类型，Byzer-lang 返回所有插件。
