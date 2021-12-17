# Kafka 开发环境搭建

我们介绍 Kafka 0.10.x 和0.9.x。这两个版本依赖Zookeeper。若没有安装， 使用 docker 可以快速搭建一个 zookeeper 环境。命令如下:

```shell
## 绑定到宿主机 2181
docker run --name some-zookeeper -p 2181:2181 --restart always -d zookeeper:3.5.9
```

## Kafka 0.9.x 0.10.0.1
以 0.10.0.1 为例说明， 0.9.x 步骤相同，将命令中版本替换后执行即可。
1. 下载并解压缩
```shell
## kafka 安装到 /work 目录
wget https://archive.apache.org/dist/kafka/0.10.0.1/kafka_2.11-0.10.0.1.tgz
tar -xf kafka_2.11-0.10.0.1.tgz -C /work/
```

2. 启动 Kafka
```shell
cd /work/kafka_2.11-0.10.0.1
bin/kafka-server-start.sh -daemon ./config/server.properties
```

3. 检查 Kafka 是否启动成功
```shell
ps -eaf | grep kafka
```


