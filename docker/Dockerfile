FROM linyuchen/qq:latest

ARG TARGETARCH
ARG PMHQ_VERSION

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl unzip \
    && rm -rf /var/lib/apt/lists/*

RUN case "$TARGETARCH" in \
        arm64) arch="arm64" ;; \
        amd64) arch="x64" ;; \
        *) echo "Unsupported architecture: $TARGETARCH" >&2; exit 1 ;; \
    esac && \
    curl --fail --location --show-error \
        "https://github.com/linyuchen/PMHQ/releases/download/v${PMHQ_VERSION}/pmhq-linux-${arch}.zip" \
        --output /opt/pmhq.zip && \
    unzip /opt/pmhq.zip -d /opt/ && \
    rm /opt/pmhq.zip && \
    mv /opt/pmhq-linux-${arch} /opt/pmhq

#COPY /dist/pmhq-linux-x64 /opt/pmhq
#COPY /dist/pmhq-linux-arm64 /opt/pmhq
RUN chmod +x /opt/pmhq
RUN cat <<EOF > /opt/pmhq_config.json
{
    "qq_path": "",
    "quick_login_qq": "",
    "enable_gui": false,
    "default_host": "0.0.0.0",
    "default_port": 13000,
    "debug": false,
    "qq_console": true,
    "headless": false
}
EOF

# 暴露端口
EXPOSE 13000

# Persist QQ user data, including saved login/session state.
RUN mkdir -p /root/.config/QQ
VOLUME ["/root/.config/QQ"]

COPY docker/startup.sh /startup.sh
RUN chmod +x /startup.sh

# 启动服务
ENTRYPOINT ["/startup.sh"]
