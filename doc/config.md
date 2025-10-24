# 配置文件

`pmhq_config.json` 是配置文件，没有此文件的话运行一次 PMHQ 就会自动生成，可以使用命令行参数 `--config` 指定配置文件路径

配置内容如下：

```json5
{
  "debug": false,
  "headless": false,
  "quick_login_qq": "12345678",
  "enable_gui": true,
  "default_host": "127.0.0.1",
  "default_port": 13000,
  "qq_path": "D:\\Program Files\\QQNT9.9.19-34958\\QQ.exe",
  "qq_console": false,
  "servers": [
    {
      "qq": 123456789,
      "host": "localhost",
      "port": 13000
    }
  ],
}
```

debug: 是否开启调试模式，开启后会输出 pb，并且 ws 会推送 send 的pb

headless: 是否启用无头 QQ 模式

quick_login_qq: 快速登录 QQ 号，如果已经登录过一次，下次启动会自动登录该 QQ

enable_gui: 是否启用 GUI 界面，仅 Windows 有效

qq_console: 是否显示 QQ 的控制台窗口

qq_path:  QQ.exe 的绝对路径

servers: 不同的 QQ 号监听不同的 ws 端口，如果 servers 不填写或者找不到对应的 QQ 号，pmhq 会使用 `default_host` 和 `default_port`


