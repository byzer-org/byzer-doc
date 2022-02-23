## Docker 镜像启动

### 1. 拉取 Byzer Notebook 镜像

```
docker pull byzer/byzer-notebook:latest
```

### 2. 启动

启动时可将通过挂载目录 `-v /path/to/conf_dir:/home/deploy/byzer-notebook/conf  ` 使用自定义的配置文件。

```shell
docker run -itd -v /path/to/conf_dir:/home/deploy/byzer-notebook/conf -p 9002:9002 --name=byzer-notebook byzer/byzer-notebook
```


