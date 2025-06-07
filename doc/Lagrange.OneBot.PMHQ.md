# 对接 Lagrange.OneBot.PMHQ

首先确认自己用的是原版 QQ，不要安装任何插件，比如安装 LiteloaderQQNT，否则依然有掉线风险

0. 下载 [PMHQ](https://github.com/linyuchen/PMHQ/releases) 和 [Lagrange.OneBot.PMHQ](https://github.com/linyuchen/Lagrange.Core.PMHQ/releases)

1. 修改 `pmhq_config.json` 的相关配置，如 QQ 号和 Port

2. 修改 `appsettings.json` 里面的 `PMHQ` 的 Host 和 Port 与 `pmhq_config.json`的一致，如果没有 `appsettings.json` 这个文件，运行一次 `Lagrange.OneBot.PMHQ` 就有了

3. 启动 PMHQ 之后登录 QQ，再启动 Lagrange.OneBot.PMHQ 即可完成对接


## 关于 Lagrange 的 OneBot 配置

修改 `appsettings.json` 里面的 `Implementations` 

正向 ws
```json5
{
  "Type": "ForwardWebSocket",
  "Host": "127.0.0.1",
  "Port": 8081,
  "HeartBeatInterval": 5000,
  "HeartBeatEnable": true,
  "AccessToken": ""
}
```

反向 ws
```json5
{
  "Type": "ReverseWebSocket",
  "Host": "127.0.0.1",
  "Port": 8080,
  "Suffix": "/onebot/v11/ws",
  "ReconnectInterval": 5000,
  "HeartBeatInterval": 5000,
  "AccessToken": ""
}
```

HTTP 服务

```json5
{
  "Type": "Http",
  "Host": "*",
  "Port": 8083,
  "AccessToken": ""
}
```

HTTP 上报

```json5
{
  "Type": "HttpPost",
  "Host": "127.0.0.1",
  "Port": 8082,
  "Suffix": "/",
  "HeartBeatInterval": 5000,
  "HeartBeatEnable": true,
  "AccessToken": "",
  "Secret": ""
}
```
