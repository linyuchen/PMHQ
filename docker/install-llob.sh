#!/bin/bash

PASSWORD=""
while [ -z "$PASSWORD" ]; do
    read -p "默认密码（必填，用于 WEBUI 和协议 token，仅支持英文和数字）: " PASSWORD
done

ENABLE_WEBUI="true"
WEBUI_PORT="3080"
SERVICE_PORTS["$WEBUI_PORT"]=1
ENABLE_HEADLESS="false"

AUTO_LOGIN_QQ=""

declare -A SERVICE_PORTS

# 交互式配置
while :; do
    clear
    echo "------------------------"
    echo "请选择服务设置："
    echo "1) 设置 WebUI 配置页端口，默认 3080"
    echo "2) 设置自动登录 QQ 号"
    echo "3) 启用无头模式（无头模式省内存，有头模式较稳定）"
    echo "0) 完成配置"
    printf "输入选项: "
    read choice # 改用不带参数的 read 兼容dash

    case $choice in
        0)
            break ;;
        1)
            while true; do
                read -p "WebUI 端口: " port
                [[ "$port" =~ ^[0-9]+$ ]] || { echo "错误：端口必须是数字！"; continue; }
                WEBUI_PORT=${port}
                break
            done
            SERVICE_PORTS["$WEBUI_PORT"]=1
            ENABLE_WEBUI="true"
            ;;
        2)
          read -p "自动登录 QQ 号（留空则不自动登录）: " AUTO_LOGIN_QQ
          ;;
        3)
            ENABLE_HEADLESS="true"
            ;;

        *)
            echo "无效选项"
            ;;
    esac
done

docker_mirror=""

read -p "是否使用docker镜像源(y/n): " use_docker_mirror

if [[ "$use_docker_mirror" =~ ^[yY]$ ]]; then
  docker_mirror="docker.1ms.run/"
fi
# 生成docker-compose.yml（使用双引号包裹并保留转义）
cat << EOF > docker-compose.yml
version: '3.8'

services:
  pmhq:
    image: ${docker_mirror}linyuchen/pmhq:latest
    container_name: pmhq
    privileged: true
    environment:
      - ENABLE_HEADLESS=${ENABLE_HEADLESS}
      - AUTO_LOGIN_QQ=${AUTO_LOGIN_QQ}
    networks:
      - app_network
    volumes:
      - qq_volume:/root/.config/QQ
      - llob_data:/app/llonebot/data

  llonebot:
    image: ${docker_mirror}linyuchen/llonebot:latest
$([ ${#SERVICE_PORTS[@]} -gt 0 ] && echo "    ports:" && for port in "${!SERVICE_PORTS[@]}"; do echo "      - \"${port}:${port}\""; done)

    extra_hosts:
      - "host.docker.internal:host-gateway"
    environment:
      - ENABLE_SATORI=${ENABLE_SATORI}
      - SATORI_PORT=${SATORI_PORT}
      - SATORI_TOKEN=${SATORI_TOKEN}
      - ENABLE_WEBUI=${ENABLE_WEBUI}
      - WEBUI_PORT=${WEBUI_PORT}
      - WEBUI_TOKEN=${PASSWORD}

    networks:
      - app_network
    volumes:
      - qq_volume:/root/.config/QQ
      - llob_data:/app/llonebot/data
    depends_on:
      - pmhq

volumes:
  qq_volume:
  llob_data:

networks:
  app_network:
    driver: bridge
EOF

printLogin(){
    if [ "$ENABLE_WEBUI" == "true" ]; then
        echo "浏览器打开 http://localhost:${WEBUI_PORT} WebUI 页面进行登录"
    else
        echo "进入容器日志扫码进行登录"
    fi
}

# 检查root权限
if [ "$(id -u)" -ne 0 ]; then
    echo "没有 root 权限，请手动运行 sudo docker compose up -d"
    printLogin
    exit 1
fi
if ! command -v docker &> /dev/null; then
  echo "没有安装 Docker！安装后运行 sudo docker compose up -d"
  printLogin
  exit 1
fi
docker compose up -d

printLogin