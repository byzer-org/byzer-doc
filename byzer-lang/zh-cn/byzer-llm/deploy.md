## 部署

## 裸机全自动化部署

> 只支持 CentOS 8 / Ubuntu 20.04 / Ubuntu 22.04

### 前置说明
1. 如果你的机器是云上的虚拟机，在创建机器资源的时候，一般都会让你设置主机名，建议主机名就叫byzerllm(确保它有sudo权限，一般默认都会有)，会少很多事情，安装脚本也只需要运行一次；
2. 如果是国外的云厂商，有一些默认参数可以调整，现在默认参数都是为国内设置的，在国外的云厂商的主机会慢不少。比如PYPI_MIRROR可以设置为default, GIT_MIRROR可以设置为github

### 具体操作

在机器上执行如下指令

```shell
git clone https://gitee.com/allwefantasy/byzer-llm
cd byzer-llm/setup-machine
```

接着切换到 Root用户下执行如下脚本：

```shell
ROLE=master ./setup-machine.sh
```

此时会完成 byzerllm 账号创建登工作。

接着 切换到 byzerllm 账号下，再次执行：

```shell
ROLE=master ./setup-machine.sh
```

会完整的安装包括显卡驱动，cuda 工具集，一整套 Byzer-LLM 环境，之后就可以访问  http://localhost:9002 来使用 Byzer-LLM 了。

> 注意，如果你的机器是从云厂商创建的虚拟机，需要使用SSH隧道端口映射，让本地也能访问远程机器的9002/9003端口，可参考下面的代码，只需把local_port替换成你希望的本地端口，remote_host替换成云主机的公网ip

```shell
ssh -L local_port:localhost:9003 byzerllm@remote_host
```

用户如果想组建集群，对于从节点，可以使用如下命令，也是分别执行两次。

```shell
ROLE=worker ./setup-machine.sh
```

> 如遇到任何问题，欢迎反馈并且提交PR。


## 手动部署

使用 Byzer-LLM 需要做如下工作：

1. 启动 Ray
2. 安装 Byzer-lang/Byzer Notebook
3. 安装 Byzer-LLM 扩展

> 注意：Byzer-LLM 需要在有 Nvidia 的 GPU 的机器上才能正常工作。推荐 Ubuntu 22.04, 同时确保安装了驱动。


### Conda 安装和配置

使用 conda 创建一个 Python 3.10.11 环境

```shell
conda create --name byzerllm-dev python=3.10.11
```

### Cuda 驱动 和 Toolkit 安装

> 重装驱动请谨慎

#### 对于Ubuntu 22.04

接着安装最新驱动：

```shell
sudo apt install nvidia-driver-535
```

重启机器：

```shell
sudo reboot
```

如果想删删除原有的驱动，可以执行如下指令：

```shell
sudo apt remove --purge nvidia-*
sudo apt autoremove --purge
```

接着安装 Nvidia Toolkit，这里推荐用conda来安装：

```shell
conda activate byzerllm-dev
conda install -y cuda -c nvidia/label/cuda-11.8.0
```

之后运行 `nvcc` 命令检查安装。

#### 对于 CentOS 8

对于 CentOS 8 可以直接通过dnf升级到最新版本：

```shell
dnf config-manager --add-repo http://developer.download.nvidia.com/compute/cuda/repos/rhel8/x86_64/cuda-rhel8.repo
dnf install -y cuda
```

接着安装 Nvidia Toolkit，这里推荐用conda来安装

```shell
conda activate byzerllm-dev
conda install -y cuda -c nvidia/label/cuda-11.8.0
```


### 启动 Deamon 进程


1. 确定切换到环境 `byzerllm-dev`，通过如下方式安装依赖：

```bash
pip install -U auto-coder
```

继续保持在环境 `byzerllm-dev`， 然后使用如下命令启动 Ray:

```bash
ray start --head
```

如果你需要使用GPU，那么可以使用如下命令启动 Ray:

```bash
CUDA_VISIBLE_DEVICES=0,1 ray start --head \
--dashboard-host 0.0.0.0 \
--num-gpus=2 \
--storage /my8t/byzerllm/ray_stroage  \
--temp-dir /my8t/byzerllm/ray_temp 
```

简要解释下，CUDA_VISIBLE_DEVICES 配置让 Ray 可以看到的 GPU,从0开始。 

1. --num-gpus 则配置 Ray 可以管理的 GPU 数，另外三个参数 
2. --object-store-memory, --storage, --temp-dir 可选。
3. --dashboard-host 是 Ray 的dashboard地址

根据自身的显卡情况填写（显卡显存需要>=8g）

### Byzer-lang/Byzer-notebook 部署

下载：

1. Byzer-lang: https://download.byzer.org/byzer-lang/2.3.9/byzer-lang-all-in-one-linux-amd64-3.3.0-2.3.9.tar.gz
2. Byzer-notebook: https://download.byzer.org/byzer-notebook/1.2.6/Byzer-Notebook-1.2.6.tar.gz

然后解压。

首先是启动 Byzer-lang 引擎，

进入 byzer-lang-all-in-one-linux-amd64-3.3.0-2.3.9 目录，执行如下命令即可启动 Byzer 引擎：

```shell
./bin/byzer.sh start
# 重启可以用下面的命令
# ./bin/byzer.sh restart
```

启动完成后就可以访问 9003 端口了。

> 注意：如果需要访问 file:// 或者对象存储的绝对路径，则需要修改 ${BYZER_HOME}/conf/byzer.properties.overwrite，添加如下配置(显示的罗列哪些schema可以用绝对路径)：
> spark.mlsql.path.schemas=oss,s3a,s3,abfs,file


启动 Byzer Notebook 则需要提前准备一个 MySQL 数据库，建议 5.7 版本的，然后创建一个名称叫做 notebook 的数据库。

现在可以进入 Byzer-Notebook-1.2.6， 修改 conf/notebook.properties 文件，

根据数据库实际地址修改数据库配置部分：

```
notebook.database.type=mysql
notebook.database.ip=127.0.0.1
notebook.database.port=3306
notebook.database.name=notebook
notebook.database.username=root
notebook.database.password=root
```

**特别注意**，下面的参数 `notebook.user.home` 务必需要修改。
该参数其实是指定的 Byzer 引擎存储用户文件数据所在的目录。你需要选一个实际可用的目录。默认的 `/mlsql` 因为在根目录下，往往Byzer引擎没有权限创建。这会导致在 Byzer-Notebook 上传文件到引擎失败等问题。

```
notebook.user.home=/mlsql
```


现在就可以启动 Notebook了：

```shell
./bin/notebook.sh start

## 重启可以用
## ./bin/notebook.sh restart
```


此时就可以访问 9002 端口了，进入 Notebook 界面开始工作了。



### Byzer-LLM 扩展安装

Byzer-LLM 作为一个扩展，可以有两种方式安装。第一种在线安装, 在 Byzer-Notebook 的 Cell 中执行如下命令：

```
!plugin app add - "byzer-llm-3.3";
```

第二种方式是离线安装, 在这个 https://download.byzer.org/byzer-extensions/nightly-build/ 中下载 byzer-llm-3.3_2.12-[最新版本].jar ， 然后将其放到 Byzer 引擎 `${BYZER_HOME}/plugin` 目录里,然后在  `${BYZER_HOME}/conf/byzer.properties.overwrite` 中添加如下参数 `streaming.plugin.clzznames=tech.mlsql.plugins.llm.LLMApp` ，因为我已经添加了一些扩展，所以这里看起来会是这样你在的：

```
streaming.plugin.clzznames=tech.mlsql.plugins.ds.MLSQLExcelApp,tech.mlsql.plugins.assert.app.MLSQLAssert,tech.mlsql.plugins.shell.app.MLSQLShell,tech.mlsql.plugins.mllib.app.MLSQLMllib,tech.mlsql.plugins.llm.LLMApp
```


## 常见问题



### bitsandbytes 异常

一般都是这样的错误：

```
RuntimeError:
        CUDA Setup failed despite GPU being available. Please run the following command to get more information:

        python -m bitsandbytes

        Inspect the output of the command and see if you can locate CUDA libraries. You might need to add them
        to your LD_LIBRARY_PATH. If you suspect a bug, please take the information from python -m bitsandbytes
        and open an issue at: https://github.com/TimDettmers/bitsandbytes/issues
```

这个可以通过手动安装 bitsandbytes 来解决。比如我的cuda版本是122（可以使用python -m bitsandbytes 来查看具体版本）。
这个时候可以按如下方式来安装：


```shell
# 使用这个地址如果github访问不畅快： https://gitee.com/allwefantasy/bitsandbytes
git clone https://github.com/timdettmers/bitsandbytes.git
cd bitsandbytes

# CUDA_VERSIONS in {110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 120}
# make argument in {cuda110, cuda11x, cuda12x}
# if you do not know what CUDA you have, try looking at the output of: python -m bitsandbytes
CUDA_VERSION=118 make cuda11x
python setup.py install

pip install .
```


此外，根据命令：python -m bitsandbytes 实际报错(没有任何报错就无需操作下面步骤，通常如果你使用conda安装的toolkit无需添加下面的内容)，可能还需要在在 `~/.bashrc` 添加如下配置(注意你的实际路径)：

```shell
export PATH=/usr/local/cuda/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:${LD_LIBRARY_PATH}
```

你可以通过运行命令 nvcc 来进行测试。

### Python 依赖库安装超时

在文件 https://github.com/allwefantasy/byzer-llm/blob/master/demo-requirements.txt 中，有些项目会直接从github/gitee安装，比如：

1. peft
2. byzerllm
3. pyjava

如果你发现会超时，可以通过类似如下方式手动安装这三个组件：

```
conda activate byzerllm-desktop
git clone https://github.com/huggingface/peft
cd perf
pip install .
```

因为涉及到torch以及cuda的依赖的安装，如果安装过慢，可以配置国内阿里云镜像。
具体做法是新增 `~/.pip/pip.conf` 文件，然后填入如下内容：

```
[global]
 trusted-host = mirrors.aliyun.com
 index-url = https://mirrors.aliyun.com/pypi/simple
```

### protobuf 安装问题

这个时候你可以先注释掉 requiments.txt里的 protobuf, 然后在安装完成后再强制执行一遍如下命令：

```
pip install protobuf==3.20.0
```

### argilla/rich 库冲突问题

类似下面的错误：

![](images/20230616-172035.jpeg)

可以先uninstall rich 然后再安装 argilla。 
如果有需要再安装指定版本 rich。





