# 对接 Lagrange.OneBot.PMHQ

此方案是稳定不掉线的一个方案

*首先确认自己用的是原版 QQ，不要安装任何插件，比如安装 LiteloaderQQNT，否则依然有掉线风险*

0. 下载 [PMHQ](https://github.com/linyuchen/PMHQ/releases) 和 [Lagrange.OneBot.PMHQ](https://github.com/linyuchen/Lagrange.Core.PMHQ/releases)

1. 修改 `pmhq_config.json` 的相关配置，如 QQ 号和 Port

2. 修改 `appsettings.json` 里面的 `PMHQ` 的 Host 和 Port 与 `pmhq_config.json`的一致，如果没有 `appsettings.json` 这个文件，运行一次 `Lagrange.OneBot.PMHQ` 就有了

3. 启动 PMHQ 之后登录 QQ，再启动 Lagrange.OneBot.PMHQ 即可完成对接

*Lagrange 的其他设置参考 [Lagrange](https://lagrangedev.github.io/Lagrange.Doc/Lagrange.OneBot/Config/) 官网*
