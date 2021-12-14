## 如何用 PyMLSQL 操作阿里云 ECS
### 前言
最近一段时间感受了下阿里云和华为云。双方铺的面都挺全。直观上来看， 阿里云控制台有一股浓郁的 toC 精致范，华为云则是企业简约朴实范，作为互联网熏陶过来的人，我显然觉得前者是更漂亮和舒适的。

华为云应该是这两三年才开始发力，有点晚，而且目前来看还在于铺面，质量还没上来，尤其是在 web 交互上和阿里云有一定的距离，目前包括非常基础的 ECS 服务都还没有 SDK，只有 API 接口。

碎碎念了，我们来看看 PyMLSQL 是如何操作阿里云 ECS，方便大家低成本去动态控制 ECS。

### 什么是 PyMLSQL
PyMLSQL 是 Kolo 一个辅助项目，目前提供两个功能：

1. 为 Kolo 的 Python 支持提供了一个可用的库。
2. 提供对云的操作封装，从而实现 Kolo 集群的自动化云端部署。
今天我们主要是介绍他的第二个功能。

### 抽象方式
对于 ECS 操作，使用原生的 API/SDK 会有如下几个问题：

比如创建或者释放 ECS 实例的动作是异步的，你需要自己去关注对应的状态。
我们需要发送 shell 命令到创建好的 ECS 实例中，从而实现自动化配置，目前 SDK 是没有相关功能的。同时我们还需要检测 ECS 启动后对应的 ssh server 是不是 ready 等。
一般而言，我们使用ECS实例其实是四步走：

启动 ECS
执行 shell 脚本配置环境
执行 shell 脚本启动服务
关闭释放 ECS
这四个步骤也是顺序执行的，需要阻塞。所以 PyMLSQL 提供三个核心命令：

* start 启动 ECS
* exec-shell 执行 shell 脚本
* stop 关闭并且释放 ECS 实例

同时，因为不可避免的需要有 client 机和 ECS 实例互传文件的需求，所以有

* copy-from-local
* copy-to-local


两个辅助指令。

由这五个指令，基本我们就能完成我们大部分任务了。

安装介绍
最简单方式：

`pip install pymlsql`

你也可以手动下载源码安装：

```python
# please make sure the x.x.x is replaced by the correct version.
pip uninstall -y pymlsql && python setup.py sdist bdist_wheel &&
cd ./dist/ && pip install pymlsql-x.x.x-py2.py3-none-any.whl && cd -
``` 
之后你就可以使用 pymlsql 命令了。

### 使用介绍
你用 `pymlsql --help` 可以获取帮助信息。

##### start 指令

```shell
pymlsql start
--image-id m-bp13ubsorlrxdb9lmv2x
--instance-type {MASTER_WITH_PUBLIC_IP}
--init-ssh-key false
--key-pair-name mlsql-build-env-local
--security-group ${SECURITY_GROUP}
```

基本上如果你懂阿里云，那么概念是比较清晰的。这里最值得关注的是后面三个参数：

* need-public-ip 是否需要公网 IP，如果你是在阿里云服务器执行指令，那这个可以设置为 false，当然，如果你需要联网下载东西，那么还是需要设置为 true 的。
* init-ssh-key 如果设置为 true，我们会自动为你生成一个秘钥，这样以后你就可以通过该秘钥登录任何通过该秘钥创建的服务器。`--key-pair-name` 设置秘钥的名字，然后改秘钥会自动生成在你的 .ssh 目录中。
* 安全组。这个你需要到阿里云控制台上先创建一个，然后指定。这个主要是为了控制 ECS 的端口访问的。


##### stop

stop 指令只要填写 instance_id 就行。

```shell
pymlsql stop --instance-id ${instance_id}  --key-pair-name mlsql-build-env-local
exec-shell
```

我们先看一个示例：

```shell
SCRIPT_FILE="/tmp/k.sh"
 
-#把脚本写入到一个文件
cat << EOF > ${SCRIPT_FILE}
#!/usr/bin/env bash
chown -R webuser:webuser /home/webuser/start-slaves.sh
chown -R webuser:webuser /home/webuser/.ssh/${MLSQL_KEY_PARE_NAME}
chmod 600 /home/webuser/.ssh/${MLSQL_KEY_PARE_NAME}
chmod u+x /home/webuser/start-slaves.sh
EOF
 
#指定脚本文件到远程执行
pymlsql exec-shell --instance-id ${instance_id} \
--script-file ${SCRIPT_FILE} \
--execute-user root
--key-pair-name mlsql-build-env-local
```

execute-user 定义以什么用户在ECS实例中执行脚本。

### 案例
利用 PyMLSQL，我们实现了完全由 shell 脚本即可在阿里云部署一套任意节点数的 Kolo 集群。
基本思路脚本会自动申请一台 ECS 实例（具有公网的），然后再登录到到 ECS 实例中去申请 slave 节点。还是很库的。