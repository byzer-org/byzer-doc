# 2021年教你尝鲜 Byzer 的 N 种方式

## 注册就可以体验
如果你是个急性子，那么你可以通过在 [Byzer 官网](http://byzer.org) 上注册一个账户就可以体验了。[这篇文章](https://mp.weixin.qq.com/s/GzQDqxuDKnVuQ7MNV4Ux4A)里有一个快速体验的章节，教大家怎么注册。

## 我只想自己笔记本上玩
那么桌面版非常适合你。参考这里的 [README](https://github.com/allwefantasy/mlsql-lang-example-project) 

下载一个 [vscode](https://so.csdn.net/so/search?from=pc_blog_highlight&q=vscode)
，然后在离线安装 Byzer-lang 插件就可以了。
PS: vscode 商店对插件大小有限制，从商店安装的话还是需要自己手动安装一些依赖，所以反倒离线安装一个 vsix 更方便。

## 我想和小伙伴一起玩玩
桌面版一般自己玩。如果想在云上或者测试环境搭建一个单机引擎，和小伙伴一起玩。

#### Docker 神器在手，天下我有
可以用 docker 版本安装到服务器上。[Sandbox 使用指南](https://docs.byzer.org/#/byzer-lang/en-us/installation/sandbox)

文档里的下载地址可能会过期。 推荐大家按如下地址下载发型包：

spark 3.1.1: https://archive.apache.org/dist/spark/spark-3.1.1/spark-3.1.1-bin-hadoop3.2.tgz
Byzer-engine: http://download.byzer.org/2.2.0-SNAPSHOT/mlsql-engine_3.0-2.2.0-SNAPSHOT.tar.gz

## 想在生产环境里用
参考:

- [引擎 K8s 部署指南](https://docs.byzer.org/#/byzer-lang/en-us/installation/byzer_engine) 
- [Yarn 部署](https://docs.byzer.org/#/byzer-lang/en-us/installation/byzer_engine) 