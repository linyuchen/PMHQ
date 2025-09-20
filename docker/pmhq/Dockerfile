FROM ubuntu:24.04

ARG TARGETARCH
ARG PMHQ_VERSION

RUN echo "Acquire::https::Verify-Peer \"false\";" > /etc/apt/apt.conf.d/99ignore-ssl && \
    echo "Acquire::https::Verify-Host \"false\";" >> /etc/apt/apt.conf.d/99ignore-ssl

RUN if [ "$TARGETARCH" = "arm64" ]; then \
        sed -i "s@http://ports.ubuntu.com/ubuntu-ports@https://mirrors.aliyun.com/ubuntu-ports@g" /etc/apt/sources.list.d/ubuntu.sources; \
    else \
        sed -i "s@http://archive.ubuntu.com/ubuntu@https://mirrors.aliyun.com/ubuntu@g; s@http://security.ubuntu.com/ubuntu@https://mirrors.aliyun.com/ubuntu@g" /etc/apt/sources.list.d/ubuntu.sources; \
    fi


# 安装核心依赖（包含 GUI 基础库）
RUN apt-get update && apt-get install -y \
    tzdata \
    xvfb \
    x11-utils \
    wget \
    unzip \
    libgtk-3-0 \
    libxcb-xinerama0 \
    libgl1-mesa-dri \
    libnotify4 \
    libnss3 \
    xdg-utils \
    libsecret-1-0 \
    libappindicator3-1 \
    libgbm1 \
    libasound2t64 \
    fonts-noto-cjk \
    libxss1 \
    && rm -rf /var/lib/apt/lists/*
    
# 设置时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone


# 下载并安装 QQ Linux 版
RUN \
    wget https://dldir1v6.qq.com/qqfile/qq/QQNT/81e26a27/linuxqq_3.2.18-36497_$TARGETARCH.deb -O qq.deb \
    && apt-get install -f -y ./qq.deb \
    && rm qq.deb

RUN if [ "$TARGETARCH" = "arm64" ]; then \
        arch="arm64"; \
    else \
        arch="x64"; \
    fi; \
    wget https://github.com/linyuchen/PMHQ/releases/download/v${PMHQ_VERSION}/pmhq-linux-${arch}.zip -O /opt/pmhq.zip && \
    unzip /opt/pmhq.zip -d /opt/ && \
    rm /opt/pmhq.zip && mv /opt/pmhq-linux-$arch /opt/pmhq

#COPY /dist/pmhq-linux-x64 /opt/pmhq
#COPY /dist/pmhq-linux-arm64 /opt/pmhq
RUN chmod +x /opt/pmhq
RUN cat <<EOF > /opt/pmhq_config.json
{
    "default_host": "0.0.0.0",
    "default_port": 13000,
    "servers": [],
    "qq_path": "",
    "headless": false
}
EOF

# 暴露端口
EXPOSE 13000

COPY docker/pmhq/startup.sh /startup.sh
RUN chmod +x /startup.sh

# 启动服务
ENTRYPOINT ["/startup.sh"]
