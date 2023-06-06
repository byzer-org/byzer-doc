# Byzer-LLM 升级指南

Byzer-LLM 由三部分组成：

1. Byzer 引擎
2. [byzer-llm](https://github.com/byzer-org/byzer-extension/tree/master/byzer-llm) 插件
3. [byzerllm](https://github.com/allwefantasy/byzer-llm) Python库
4. [pyjava](https://github.com/byzer-org/byzer-python/tree/master/python) Python库

升级分成两部分：

1. byzer-llm 插件 和  pyjava/byzerllm Python库升级。 他们三者通常要同时升级
2. Byzer 引擎升级

Byzer引擎升级只要按安装文档说明即可完成。现在主要插件和pyjava/byzerllm 两个 Python库的升级。

## byzer-llm 插件升级

两种方式。第一种方式是离线安装的，那么可以 https://download.byzer.org/byzer-extensions/nightly-build/ 中下载最新的 byzer-llm 插件，
放到 ${BYZER_HOME}/plugin 目录下，然后在 ${BYZER_HOME}/conf/byzer.properties.overwrite 中添加：

```
streaming.plugin.clzznames=tech.mlsql.plugins.llm.LLMApp
```

如果有多个插件，按逗号分割。比如我机器的是这样的：

```
streaming.plugin.clzznames=tech.mlsql.plugins.ds.MLSQLExcelApp,tech.mlsql.plugins.assert.app.MLSQLAssert,tech.mlsql.plugins.shell.app.MLSQLShell,tech.mlsql.plugins.mllib.app.MLSQLMllib,tech.mlsql.plugins.llm.LLMApp,tech.mlsql.plugins.execsql.ExecSQLApp
```

重启引擎即可。

第二种是在线安装：

```shell
!plugin app remove "byzer-llm-3.3";
!plugin app add - "byzer-llm-3.3";
```

然后重启引擎。

## pyjava/byzerllm Python库升级

通过 conda activate 进入你的环境：

byzerllm 升级：

```shell
git clone https://github.com/allwefantasy/byzer-llm
cd byzer-llm

## 防止依赖更新
pip install -r requirements.txt

## 安装 byzerllm 自身
pip install .
```

pyjava 升级：

```shell
git clone https://github.com/byzer-org/byzer-python
cd byzer-python/python

## 安装 pyjava 自身
pip install .
```

升级这两个python库之后，需要重启 Ray/Byzer引擎。
