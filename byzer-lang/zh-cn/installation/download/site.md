# Byzer 下载渠道

Byzer 社区提供了以下三种官方下载渠道，为用户提供相关的资源下载


### 官方下载站点（推荐）
官方下载站点地址： [https://download.byzer.org/](https://download.byzer.org/)， 该站点提供了 Byzer 引擎，Byzer Notebook，Byzer 引擎插件，Byzer VSCode Extension 等产品二进制包下载。

目录结构组织如下：

```shell
|- byzer                           # 提供 Byzer 引擎的下载
    |- {released-versions}         #
    |- nighlty-build               #
    |- misc                        # 提供一些 Byzer 相关依赖，比如 JDK, jar 文件等
|- byzer-extensions                # 提供 Byzer Extension 的二进制包下载，注意 Byzer Extension 目前只有 nightly build 版本
    |- nighlty-build               #
|- byzer-notebook                  # 提供 Byzer Notebook 的二进制包下载
    |- {released-versions}         #
    |- nighlty-build               #
|- k8s-helm                        # 提供相关产品包的 helm chart 下载
    |- byzer-lang                  #
    |- byzer-notebook              #
    |- dophinscheduler             # 
    |- ngix-ingress                #
```

> **注意**
> 为了提高用户的下载速度和体验，该下载站点启用了 AWS CloudFront 的 CDN，不同地区的用户可能会存在由于缓存未及时更新的问题，如果您碰到了此种情况，可以等一段时间后再进行访问

### Docker Hub（推荐）

Byzer 社区将 Byzer 的产品镜像，包括 Byzer Sandbox 镜像， Byzer 引擎镜像， Byzer Notebook 镜像以及 Byzer 引擎 K8S 镜像等，托管至 [Byzer docker hub](https://hub.docker.com/u/byzer)，方便用户通过 Docker 或 K8S 等技术来进行使用


### Github Release

Byzer 社区在版本发布时，会在 Byzer-lang 项目以及 Byzer Notebook 项目提供已正式发布的产品的 Release Note 以及对应版本的二进制包和源代码：
- [Byzer-lang Release](https://github.com/byzer-org/byzer-lang/releases)
- [Byzer Notebook Release](https://github.com/byzer-org/byzer-notebook/releases)

