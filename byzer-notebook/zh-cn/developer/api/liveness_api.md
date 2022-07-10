# 实例状态检测 Liveness API


Byzer Notebook 从 v1.2.1 引入 Liveness API 用于检测系统的状态，共有两个 API

 -`GET /api/system/liveliness`，判断服务是否存活，200 状态码标识系统正常，非 200 状态码标识系统已挂
 -`GET /api/system/readiness`，判断服务是否可用，200 状态码标识系统正常，非 200 状态码标识系统不可用
