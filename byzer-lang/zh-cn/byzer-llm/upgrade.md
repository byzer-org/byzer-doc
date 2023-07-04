# Byzer-LLM 升级指南

Byzer-LLM 由四个部分组成：

1. Byzer 引擎
2. [byzer-llm](https://github.com/byzer-org/byzer-extension/tree/master/byzer-llm) 插件
3. [byzerllm](https://github.com/allwefantasy/byzer-llm) Python库
4. [pyjava](https://github.com/byzer-org/byzer-python/tree/master/python) Python库

这里容易搞混 byzer-llm jar包和 byzerllm Python 包。你可以理解为两者实现了 Java/Scala 和 Python的沟通桥梁。

升级主要分成两部分：

1. byzer-llm 插件 和  pyjava/byzerllm 两个Python库升级，通常我们我们需要对三者同时进行升级
2. Byzer 引擎升级

Byzer引擎升级只要 Byzer 安装文档说明即可完成。
该文主要介绍如何升级插件和 pyjava/byzerllm 两个 Python库。

## byzer-llm 插件升级

根据不同的安装方式，可以选择不同的升级方式。

第一种离线安装方式。可以从 https://download.byzer.org/byzer-extensions/nightly-build/ 链接中下载最新的 byzer-llm 插件，
放到 ${BYZER_HOME}/plugin 目录下替换原来的版本的插件，如果是第一次，则还需要在 ${BYZER_HOME}/conf/byzer.properties.overwrite 中添加配置：

```
streaming.plugin.clzznames=tech.mlsql.plugins.llm.LLMApp
```

如果有多个插件，按逗号分割。比如我机器的是这样的：

```
streaming.plugin.clzznames=tech.mlsql.plugins.ds.MLSQLExcelApp,tech.mlsql.plugins.assert.app.MLSQLAssert,tech.mlsql.plugins.shell.app.MLSQLShell,tech.mlsql.plugins.mllib.app.MLSQLMllib,tech.mlsql.plugins.llm.LLMApp,tech.mlsql.plugins.execsql.ExecSQLApp
```

重启引擎即可。

第二种是在线安装：

```sql
-- 删除原有插件
!plugin app remove "byzer-llm-3.3";

-- 再次安装插件
!plugin app add - "byzer-llm-3.3";
```

然后重启引擎。

## pyjava/byzerllm Python库升级

通过 conda activate 进入你的环境：

byzerllm 升级：

```shell
## gitee: https://gitee.com/allwefantasy/byzer-llm
git clone https://github.com/allwefantasy/byzer-llm
cd byzer-llm

## 拉取最新代码
git pull origin master

## 安装 byzerllm 自身
pip install .
```

pyjava 升级：

```shell

# gitee: https://gitee.com/allwefantasy/byzer-python 
git clone https://github.com/byzer-org/byzer-python
cd byzer-python/python

## 拉取最新代码
git pull origin master

## 安装 pyjava 自身
pip install .
```

升级这两个python库之后，需要重启 Ray/Byzer引擎。
