# Liveness 探针

> Byzer-lang 2.1.0-SNAPSHOT及以上可用

Byzer-lang 支持 K8s 的 liveness 探针。对应接口为

```
http://<ip>:9003/health/liveness
```

如果处于可用状态，返回200,结果如下：

```json

{
  "status": "UP",
  "components": {
    "livenessProbe": {
      "status": "UP"
    }
  }
}
```

如果系统不可用，返回500,结果如下：

```json
{
  "status": "DOWN",
  "components": {
    "livenessProbe": {
      "status": "DOWN"
    }
  }
}
```
