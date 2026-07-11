# 配置文件

`pmhq_config.json` 是配置文件。没有此文件时 PMHQ 会以默认配置运行；需要自定义时手动新建即可，也可以用命令行参数 `--config` 指定配置文件路径。

配置内容如下：

```json5
{
  "qq_path": "D:\\Program Files\\QQNT9.9.19-34958\\QQ.exe",
  "quick_login_qq": "12345678",
  "default_host": "127.0.0.1",
  "default_port": 13000,
  "auth_token": "",
  "pmhq_api_token": "",
  "debug": false,
  "debug_pb": false,
  "qq_console": false,
  "qq_args": "",
  "sub_cmd": ""
}
```

## 配置项说明

| 字段 | 说明 |
|---|---|
| `qq_path` | QQ 可执行文件的绝对路径（Windows 为 `QQ.exe`）。留空时会自动探测。 |
| `quick_login_qq` | 快速登录的 QQ 号。填了会在启动后自动点选该账号登录。 |
| `default_host` | 本地 HTTP/WS API 监听地址，默认 `127.0.0.1`。要让其他机器访问填 `0.0.0.0`。 |
| `default_port` | 本地 HTTP/WS API 端口，默认 `13000`。 |
| `auth_token` | manager-server 鉴权凭证，必填，否则启动时会拒绝运行。到 https://auth.luckylillia.com 获取。 |
| `pmhq_api_token` | 本地 HTTP/WS API 的访问鉴权（Bearer token）。留空 = 不鉴权（任何人可访问本地 API）。跟 `auth_token` 是两回事。 |
| `debug` | 调试模式，开启后输出 pb，且 WS 会推送 send 的 pb。 |
| `debug_pb` | 单独控制是否打印 send/recv 包日志。 |
| `qq_console` | 是否显示 QQ 的控制台窗口（仅 Windows）。 |
| `qq_args` | 追加给 QQ 的启动参数（按 shell 规则切分）。 |
| `sub_cmd` | PMHQ 运行后执行的子命令，可用来启动子进程（如机器人框架）。 |

## 命令行参数

命令行参数优先级高于配置文件，可用于临时覆盖：

| 参数 | 说明 |
|---|---|
| `--config <path>` | 指定配置文件路径 |
| `--qq <number>` | 快速登录 QQ 号（覆盖 `quick_login_qq`） |
| `--qq-path <path>` | QQ 路径 |
| `--qq-args <args>` | 追加给 QQ 的启动参数 |
| `--host <host>` | API 监听地址 |
| `--port <port>` | API 端口 |
| `--auth-token <token>` | manager-server 鉴权凭证 |
| `--api-token <token>` | 本地 API 鉴权 token |
| `--attach-existing` | 注入已运行的 QQ（默认是自己启动新 QQ） |
| `--pid <pid>` | 注入指定 PID 的 QQ 进程，仅 Windows 可用 |
| `--debug` / `--debug-pb` | 调试 / 包日志 |
