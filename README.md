# PMHQ

Pure memory hook for QQNT

## JS plugin development

See [plugin.md](./doc/plugin.md) for information about developing JavaScript plugins.

## API integration

- For sending and receiving Protobuf over the API, see [API.md](./doc/api.md).

## Integrating with LLOneBot

- See the official LLOneBot website: https://llonebot.com

## Integrating with Lagrange.OneBot.PMHQ

- See [Lagrange.OneBot.PMHQ.md](./doc/Lagrange.OneBot.PMHQ.md).

## Docker

On Linux you can deploy PMHQ together with LLOneBot using the one-line Docker install script:

```shell
curl -fsSL https://raw.githubusercontent.com/linyuchen/PMHQ/refs/heads/main/docker/install-llob.sh -o install-pmhq-llob.sh && chmod u+x ./install-pmhq-llob.sh && ./install-pmhq-llob.sh
```

On Linux you can deploy PMHQ together with Lagrange.OneBot.PMHQ using the one-line Docker install script:

```shell
curl -fsSL https://raw.githubusercontent.com/linyuchen/PMHQ/refs/heads/main/docker/install-lgr.sh -o install-pmhq-lgr.sh && chmod u+x ./install-pmhq-lgr.sh && ./install-pmhq-lgr.sh
```

## macOS

You need to disable SIP (System Integrity Protection) and then start PMHQ with `sudo`.

## Configuration

Configuration file reference: [config.md](./doc/config.md)
