FROM linyuchen/qq:latest

ARG TARGETARCH
ARG PMHQ_VERSION

COPY /dist/pmhq-linux-x64 /opt/pmhq
#COPY /dist/pmhq-linux-arm64 /opt/pmhq
RUN chmod +x /opt/pmhq
RUN cat <<EOF > /opt/pmhq_config.json
{
    "default_host": "0.0.0.0",
    "default_port": 13000,
    "servers": [],
    "qq_path": "",
    "headless": false,
    "quick_login_qq": ""
}
EOF

# 暴露端口
EXPOSE 13000

COPY docker/pmhq/startup.sh /startup.sh
RUN chmod +x /startup.sh

# 启动服务
ENTRYPOINT ["/startup.sh"]
