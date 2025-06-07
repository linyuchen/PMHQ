FROM ubuntu:24.04
ARG TARGETARCH

RUN echo "Acquire::https::Verify-Peer \"false\";" > /etc/apt/apt.conf.d/99ignore-ssl && \
    echo "Acquire::https::Verify-Host \"false\";" >> /etc/apt/apt.conf.d/99ignore-ssl

RUN if [ "$TARGETARCH" = "arm64" ]; then \
        sed -i "s@http://ports.ubuntu.com/ubuntu-ports@http://mirrors.aliyun.com/ubuntu-ports@g" /etc/apt/sources.list.d/ubuntu.sources; \
    else \
        sed -i "s@http://archive.ubuntu.com/ubuntu@http://mirrors.aliyun.com/ubuntu@g; s@http://security.ubuntu.com/ubuntu@http://mirrors.aliyun.com/ubuntu@g" /etc/apt/sources.list.d/ubuntu.sources; \
    fi

RUN apt-get update && apt install -y wget unzip openssl libicu74 jq \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY /docker/lagrange-onebot-pmhq/appsettings.json /app/appsettings.json

RUN \
    if [ "$TARGETARCH" = "arm64" ]; then \
      arch="arm64"; \
    else \
      arch="x64"; \
    fi; \
    wget --show-progress "https://gh-proxy.com/https://github.com/linyuchen/Lagrange.Core.PMHQ/releases/latest/download/Lagrange.OneBot.PMHQ.linux-$arch.zip" \
    && unzip -j Lagrange.OneBot.PMHQ.linux-$arch.zip \
    && rm Lagrange.OneBot.PMHQ.linux-$arch.zip \
    && mv Lagrange.OneBot.PMHQ.linux-$arch Lagrange.OneBot.PMHQ \
    && chmod +x Lagrange.OneBot.PMHQ

COPY /docker/lagrange-onebot-pmhq/startup.sh /app/startup.sh

ENTRYPOINT ["./startup.sh"]