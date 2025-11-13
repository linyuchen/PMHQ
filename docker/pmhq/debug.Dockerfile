FROM linyuchen/qq:latest

ARG TARGETARCH
ARG PMHQ_VERSION

COPY /dist/pmhq-linux-x64 /opt/pmhq
#COPY /dist/pmhq-linux-arm64 /opt/pmhq
RUN chmod +x /opt/pmhq
RUN cat <<EOF > /opt/pmhq_config.json
{
    "qq_path": "",
    "quick_login_qq": "",
    "enable_gui": false,
    "default_host": "0.0.0.0",
    "default_port": 13000,
    "debug": true,
    "qq_console": true,
    "headless": false
}
EOF

# 暴露端口
EXPOSE 13000

COPY docker/pmhq/startup.sh /startup.sh
RUN chmod +x /startup.sh

# 启动服务
ENTRYPOINT ["/startup.sh"]
