# PMHQ

Pure memory hook QQNT

# 使用说明

启动 pmhq 之后会启动一个 Websocket 服务监听 13000

连接 `ws://localhost:13000/ws`

## 发包
```json5
{
  "type": "send",
  "data": {
    "echo": "1", //用于获取发送结果的标识符
    "cmd": "OidbSvcTrpcTcp.0xED3_1",  
    "pb":  "08d31d1001221408d6e7f7b4011094de88840228d6e7f7b40130006001" // protobuf 的 hex string
  }
}
```

## 收包
```json5
{
  "type": "recv",
  "data": {
    "echo": "1", // 和发送的对应
    "cmd": "OidbSvcTrpcTcp.0xED3_1",  
    "pb":  "08d3...." // protobuf 的 hex string
  },
  "code": 0,  // 非 0 表示失败
  "message": ""  // 错误信息
}
```

## HTTP 的方式调用

由于 HTTP 调用不是异步操作，所以不需要 echo 字段

POST http://localhost:13000/

request payload JSON
```json5
{
  "type": "send",
  "data": {
    "cmd": "OidbSvcTrpcTcp.0xED3_1",  
    "pb":  "08d31d1001221408d6e7f7b4011094de88840228d6e7f7b40130006001" // protobuf 的 hex string
  }
}
```

response JSON
```json5
{
  "type": "recv",
  "data": {
    "cmd": "OidbSvcTrpcTcp.0xED3_1",  
    "pb":  "08d3...." // protobuf 的 hex string
  },
  "code": 0,  // 非 0 表示失败
  "message": ""  // 错误信息
}
```


## 调用封装好的函数

payload JSON
```json5
{
  "type" : "call",
  "data" : {
    "func" : "", // 函数名
    "args": []  // 参数列表
  }
}
```

### 获取登录的 uin 和 uid

payload JSON
```json5
{
  "type" : "call",
  "data" : {
    "echo": "212de1d8-a614-42c5-b03a-cc7b156b3b73",
    "func" : "getSelfInfo",
    "args": []
  }
}
```

response JSON
```json5
{
    "code": 0,
    "message": "",
    "type": "call",
    "data": {
        "echo": "212de1d8-a614-42c5-b03a-cc7b156b3b73",
        "result": {
            "uin": "123456",
            "uid": "u_qjJASIDF-asdfasdfsd-w"
        }
    }
}
```

## 配置文件

`pmhq_config.json` 是配置文件，里面可以配置

* QQ.exe 的绝对路径
* 不同的 QQ 号监听不同的 ws 端口

如果你的 pmhq 位于 QQ.exe 的上级目录，pmhq 会自动寻找到 QQ.exe，则不需要填写 `qq_path`

## 对接 Lagrange.OneBot.PMHQ

见 [Lagrange.OneBot.PMHQ.md](./Lagrange.OneBot.PMHQ.md)

