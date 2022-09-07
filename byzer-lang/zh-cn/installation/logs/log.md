# Byzer 引擎日志说明

### 日志文件
Byzer 引擎运行日志将会生成在 `$BYZER_HOME/logs` 文件夹内，结构如下：

```shell
$BYZER_HOME/logs
  |- byzer-lang.log             # Byzer 引擎产生的主日志文件
  |- byzer.out                  # Byzer 引擎产生的标准日志输出，包含 Springboot 等日志信息
  |- shell.stderr               # 命令行执行输出的所有日志信息
  |- shell.stdout               # 命令行执行输出的标准日志输出
  |- check-env.error            # 执行 `check-env.sh` 产生的错误日志输出
  |- check-env.out              # 执行 `check-env.sh` 产生的标准日志输出
  |- security.log               # 操作执行记录日志，包含执行操作，执行人，以及时间等信息
```

### 调整日志配置

Byzer 引擎的日志配置位于目录 `$BYZER_HOME/conf` 目录下，包含如下文件

```shell
|- log4j.properties                       # Byzer 引擎主日志配置
|- byzer-server-log4j.properties          # Byzer 引擎服务端日志配置
|- byzer-tools-log4j.properties           # Byzer 可执行命令中调用的 Java 类的日志配置
```

您可以根据您的需要修改上述日志配置文件来日志级别和输出的格式。

### 自定义 API 返回报错模板

从 Byzer 引擎 `2.3.3` 版本开始，Byzer 引擎提供了自定义 API 返回消息的静态替换模板功能，用户可以自行定义返回消息体。

用户可以在 `$BYZER_HOME/conf/` 目录下创建或编辑已有的 `err-msg-template.json` 格式的文件，该文件格式如下：

```json
[
  { "regexp": "MLSQL Parser error in .*?", "msg": "MLSQL Parser error"}
]
```

在该文件中，用户可以自定义不同的 API 消息的正则匹配表达式作为 `regexp` 的值，然后将需要替换的文本定义在 `msg` 中，当 API 返回匹配到制定的表达式时，就会将 API 返回消息体中的 message 替换为用户自定义的消息体，在保证灵活性的前提下，提高 API 返回消息的可读性。