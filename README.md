# PMHQ

Pure memory hook QQNT

## JS 插件开发

见 [plugin.md](./doc/plugin.md)

## API 对接

* 使用 API 收发 Protobuf 见 [API.md](./doc/api.md)

## 对接 LLOneBot

* 见 [LLOneBot 官网](https://llonebot.com)
 
## 对接 Lagrange.OneBot.PMHQ 

* 见 [Lagrange.OneBot.PMHQ.md](./doc/Lagrange.OneBot.PMHQ.md)

## Docker

Linux 使用 Docker 一键脚本部署 PMHQ 和 LLOneBot
```shell
curl -fsSL https://raw.githubusercontent.com/linyuchen/PMHQ/refs/heads/main/docker/install-llob.sh -o install-pmhq-llob.sh && chmod u+x ./install-pmhq-llob.sh && ./install-pmhq-llob.sh
```

Linux 使用 Docker 一键脚本部署 PMHQ 和 Lagrange.OneBot.PMHQ
```shell
curl -fsSL https://raw.githubusercontent.com/linyuchen/PMHQ/refs/heads/main/docker/install-lgr.sh -o install-pmhq-lgr.sh && chmod u+x ./install-pmhq-lgr.sh && ./install-pmhq-lgr.sh
```

## macOS

需要关闭 SIP，然后 sudo 启动

## 配置

配置文件参考 [配置文件文档](./doc/config.md)
