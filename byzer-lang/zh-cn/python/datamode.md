# dataMode 详解

在运行 Byzer-python 时，`dataMode` 是必须设置的。`dataMode` 可选值为 `data/model`：

#### `data`

如果你在代码中使用了 `RayContext.foreach` 或 `RayContext.map_iter`，那么需要设置 `dataMode` 为 `data`。 在这种模式下，数据会经过 Ray 集群分布式处理并且不通过 Ray
Client (Python Worker) 端回流到 Byzer-engine。

#### `model`

上述情况外，`dataMode` 均需设置为 `model`。
