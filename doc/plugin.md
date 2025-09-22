# PMHQ 支持加载 js 插件

插件有点类似于 LiteLoaderQQNT 的插件，但是不支持 LiteLoader 相关的 API

也可以使用本仓库修改过的 LiteLoaderQQNT 作为 PMHQ 的插件加载，不过可能有掉线风险

插件放在 PMHQ 同级目录的 `plugins` 目录下，pmhq 启动时会自动加载

如果 preload 脚本没有被加载，需要在 `pmhq_config.json` 启用 `qq_console`

插件示例见本仓库的 [plugins](https://github.com/linyuchen/PMHQ/tree/main/plugins)

## PMHQ api

在 main 进程中可以使用 `global.PMHQ` 操作一些api

`global.PMHQ.wrapperSession`, WrapperSession 对象

`global.PMHQ.loginService`, LoginService 对象

`global.PMHQ.sendPb(cmd: string, pbHex: string)=>void`, 可发送Protobuf

