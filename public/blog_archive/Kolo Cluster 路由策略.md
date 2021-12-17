## Byzer Cluster 路由策略
### 前言
Byzer Cluster 具备多 Byzer Engine 实例管理功能，实现负载均衡，多业务切分等等功能。

### 负载均衡
Byzer Cluster 有一个和 Byzer Engine 完全一致的 /run/script 接口，参数也是保持一致的。

在 Byzer Engine 的基础上，多出了两个参数：

```
tags 
proxyStrategy
```
tags 决定访问哪些 engine, proxyStrategy 决定如何访问这些 Engine.proxyStrategy 的可选参数有：

```
ResourceAwareStrategy      资源剩余最多的 Engine 将获得本次请求
JobNumAwareStrategy        任务数最少的 Engine 将获得本次请求
AllBackendsStrategy        所有节都将获得本次请求
默认是 ResourceAwareStrategy 策略。
```

一个简单的请求如下：

```shell
curl -XPOST http://127.0.0.1:8080 -d 'sql=....& tags=...& proxyStrategy=JobNumAwareStrategy'
```