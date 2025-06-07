FROM ubuntu:24.04

ARG TARGETARCH

RUN echo "Acquire::https::Verify-Peer \"false\";" > /etc/apt/apt.conf.d/99ignore-ssl && \
    echo "Acquire::https::Verify-Host \"false\";" >> /etc/apt/apt.conf.d/99ignore-ssl

RUN if [ "$TARGETARCH" = "arm64" ]; then \
        sed -i "s@http://ports.ubuntu.com/ubuntu-ports@http://mirrors.aliyun.com/ubuntu-ports@g" /etc/apt/sources.list.d/ubuntu.sources; \
    else \
        sed -i "s@http://archive.ubuntu.com/ubuntu@http://mirrors.aliyun.com/ubuntu@g; s@http://security.ubuntu.com/ubuntu@http://mirrors.aliyun.com/ubuntu@g" /etc/apt/sources.list.d/ubuntu.sources; \
    fi

# 安装核心依赖（包含 GUI 基础库）


RUN apt-get update && apt-get install -y \
    xvfb \
    x11vnc \
    x11-utils \
    websockify \
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
    && rm -rf /var/lib/apt/lists/*

# 安装 noVNC
RUN wget https://gh-proxy.com/https://github.com/novnc/noVNC/archive/refs/tags/v1.6.0.zip \
    && unzip v1.6.0.zip \
    && rm v1.6.0.zip \
    && mv noVNC-1.6.0 /opt/novnc \
    && ln -s /opt/novnc/utils/novnc_proxy /usr/local/bin/novnc

# 下载并安装 QQ Linux 版
RUN \
    wget https://dldir1.qq.com/qqfile/qq/QQNT/69629a30/linuxqq_3.2.17-35341_$TARGETARCH.deb -O qq.deb \
    && apt-get install -f -y ./qq.deb \
    && rm qq.deb

# 设置 VNC 密码
# 从环境变量获取密码，默认值为 pmhq
ARG VNC_PASSWORD=pmhq
ENV VNC_PASSWORD=$VNC_PASSWORD
RUN mkdir -p ~/.vnc && x11vnc -storepasswd "$VNC_PASSWORD" ~/.vnc/passwd

#RUN if [ "$TARGETARCH" = "arm64" ]; then \
#        arch="arm64"; \
#    else \
#        arch="x64"; \
#    fi; \
#    wget https://gh-proxy.com/https://github.com/linyuchen/PMHQ/releases/latest/download/pmhq-linux-${arch}.zip -O /opt/pmhq.zip && \
#    unzip /opt/pmhq.zip -d /opt/ && \
#    rm /opt/pmhq.zip && mv /opt/pmhq-linux-$arch /opt/pmhq

COPY /dist/pmhq-linux-x64 /opt/pmhq
#COPY /dist/pmhq-linux-arm64 /opt/pmhq
RUN chmod +x /opt/pmhq
RUN cat <<EOF > /opt/pmhq_config.json
{
    "default_host": "0.0.0.0",
    "default_port": 13000,
    "servers": [],
    "qq_path": ""
}
EOF



# 暴露端口
EXPOSE 6080 5900 13000

COPY docker/pmhq/startup.sh /startup.sh
RUN chmod +x /startup.sh

# 启动服务
ENTRYPOINT ["/startup.sh"]
