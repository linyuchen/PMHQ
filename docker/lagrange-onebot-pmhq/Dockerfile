FROM docker.m.daocloud.io/library/ubuntu:24.04
RUN sed -i "s@http://archive.ubuntu.com@http://mirrors.aliyun.com@g; s@http://security.ubuntu.com@http://mirrors.aliyun.com@g" /etc/apt/sources.list.d/ubuntu.sources

RUN apt-get update && apt install -y wget unzip openssl libicu74 jq \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY /docker/lagrange-onebot-pmhq/appsettings.json /app/appsettings.json

RUN wget --show-progress "https://gh-proxy.com/https://github.com/linyuchen/Lagrange.Core.PMHQ/releases/latest/download/Lagrange.OneBot.PMHQ.linux-x64.zip" \
    && unzip -j Lagrange.OneBot.PMHQ.linux-x64.zip \
    && rm Lagrange.OneBot.PMHQ.linux-x64.zip \
    && chmod +x Lagrange.OneBot.PMHQ.linux-x64

COPY /docker/lagrange-onebot-pmhq/startup.sh /app/startup.sh

ENTRYPOINT ["./startup.sh"]