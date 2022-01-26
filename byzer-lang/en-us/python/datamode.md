# DataMode instruction

`dataMode` is required when running Byzer-python. The optional value of`dataMode` is `data/model`:

#### `data`

If you use `RayContext.foreach` or `RayContext.map_iter` in your code, you need to set `dataMode` to `data`. In this mode, data will  do distributed processing through Ray cluster but not through Ray Client (Python Worker). Then data returns to Byzer-engine.

#### `model`

Except the above case, `dataMode` must be set to `model`.
