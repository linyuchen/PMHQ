# PMHQ

Pure memory hook QQNT

不修改 QQ 文件，纯内存 Hook 实现，可用于收发 Protobuf

## API 对接

* 使用 API 收发 Protobuf 见 [API.md](./doc/api.md)

## 对接 Lagrange.OneBot.PMHQ 

* 见 [Lagrange.OneBot.PMHQ.md](./doc/Lagrange.OneBot.PMHQ.md)

## 对接 LLOneBot

* 见 [LLOneBot 官网](https://llonebot.com)

## Docker

Linux 使用 Docker 一键脚本部署 PMHQ 和 Lagrange.OneBot.PMHQ
```shell
curl -fsSL https://raw.githubusercontent.com/linyuchen/PMHQ/refs/heads/main/docker/install-lgr.sh -o install-pmhq-lgr.sh && ./install-pmhq-lgr.sh
```

Linux 使用 Docker 一键脚本部署 PMHQ 和 LLOneBot
```shell
curl -fsSL https://raw.githubusercontent.com/linyuchen/PMHQ/refs/heads/main/docker/install-llob.sh -o install-pmhq-llob.sh && ./install-pmhq-llob.sh
```

## 配置

配置文件参考 [配置文件文档](./doc/config.md)
