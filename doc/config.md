# 配置文件

`pmhq_config.json` 是配置文件，没有此文件的话运行一次 PMHQ 就会自动生成

配置内容如下：

```json5
{
  "default_host": "127.0.0.1",
  "default_port": 13000,
  "qq_path": "D:\\Program Files\\QQNT9.9.19-34958\\QQ.exe",
  "servers": [
    {
      "qq": 123456789,
      "host": "localhost",
      "port": 13000
    }
  ],
}
```

qq_path:  QQ.exe 的绝对路径

servers: 不同的 QQ 号监听不同的 ws 端口，如果 servers 不填写或者找不到对应的 QQ 号，pmhq 会使用 `default_host` 和 `default_port`

如果你的 pmhq 位于 QQ.exe 的上级目录，pmhq 会自动寻找到 QQ.exe，则不需要填写 `qq_path`

