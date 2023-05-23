## 学会查看 Ray 日志

Byzer-LLM 目前会使用 Ray 部署模型。 Ray 提供了一个 dashboard 地址 通常为：

```
http://127.0.0.1:8265/#/new/actors
```

当你执行模型部署命令后，可以通过上面的dashboard 查看实际部署情况。

![](images/screenshot-20230523-165512.png)

可以看到，我们部署的 chat 函数已经都处于 alive状态了。（一般是一个 UDFMaster 对应一个或者多个 UDFWorker）.

每个 Actor 都可以点击进去查看任务运行状态（比如你使用大模型执行了一次交互）：

![](images/screenshot-20230523-165721.png)