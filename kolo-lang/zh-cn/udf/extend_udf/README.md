# 动态创建UDF/UDAF

Kolo 支持使用 Python、Java、Scala 编写UDF/UDAF。无需打包或重启，只需运行注册UDF的Kolo代码，就可以即时生效。极大的方便用户自定义扩展Kolo的功能。

对于Python UDF，特别说明以下几点：

1. Kolo支持 Python 版本为 2.7.1
2. Python不支持任何native库，比如numpy.
3. Python必要指定返回值，否则
4. 我们提供了专门的交互式Python语法以及大规模数据处理的Python语法，用以弥补Python UDF的不足。在Python专门章节 我们会提供更详细的介绍。

所以我们建议对于python尽可能只做简单的文本解析处理，以及使用原生自带的库。

