# Readiness 探针

> Byzer-lang 2.1.0-SNAPSHOT及以上可用

Byzer-lang 支持 K8s 的 Readiness 探针。对应接口为

```
http://<ip>:<port>/health/readiness
```
port 默认为 9003 . 如果已经初始化完成，处于可用状态，返回200,结果如下：

```json
{
  "status": "IN_SERVICE",
  "components": {
    "readinessProbe": {
      "status": "IN_SERVICE"
    }
  }
}
```

如果系统还未初始化完成，返回 503, 结果如下：

```json
{
  "status": "OUT_OF_SERVICE",
  "components": {
    "readinessProbe": {
      "status": "OUT_OF_SERVICE"
    }
  }
}
```
