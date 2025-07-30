#!/bin/bash

if ! command -v docker &> /dev/null; then
  echo "请先安装 Docker！"
  exit 1
fi

# 用户输入
read -p "noVNC 端口（默认 6080）: " NOVNC_PORT
NOVNC_PORT=${NOVNC_PORT:-6080}

VNC_PASSWORD=""
while [ -z "$VNC_PASSWORD" ]; do
    read -p "VNC 密码（必填）: " VNC_PASSWORD
done

ONEBOT_TOKEN=""
ONEBOT_SECRET=""
ONEBOT_WS_URLS="["
ONEBOT_HTTP_URLS="["
ENABLE_ONEBOT_WS="false"
ENABLE_ONEBOT_HTTP="false"
ONEBOT_WS_PORT="3001"
ONEBOT_HTTP_PORT="3000"

ENABLE_SATORI="false"
SATORI_PORT="5600"
SATORI_TOKEN=""

ENABLE_WEBUI="false"
WEBUI_PORT=""

declare -A SERVICE_PORTS

# 交互式配置
while :; do
    clear
    echo "------------------------"
    echo "请选择服务设置："
    echo "1) 设置OneBot 11正向WS"
    echo "2) 添加OneBot 11反向WS"
    echo "3) 设置OneBot 11 HTTP服务"
    echo "4) 添加OneBot 11 HTTP上报"
    echo "5) 设置OneBot 11 HTTP POST secret"
    echo "6) 设置OneBot 11 Token"
    echo "7) 设置Satori端口"
    echo "8) 设置Satori token"
    echo "9) 设置WebUI端口"
    echo "0) 完成配置"
    printf "输入选项 (0-6): "
    read choice # 改用不带参数的 read 兼容dash

    case $choice in
        0)
            ONEBOT_WS_URLS+="]"
            ONEBOT_HTTP_URLS+="]"
            break ;;
        1|3)
            # 正向WS/HTTP服务
            # 端口验证
            while true; do
                read -p "Port: " port
                [[ "$port" =~ ^[0-9]+$ ]] || { echo "错误：端口必须是数字！"; continue; }
                port=${port}
                break
            done

            if [ "$choice" == "1" ]; then
                if [ "$ONEBOT_HTTP_PORT" == "$port" ]; then
                    echo "错误：WS端口不能与HTTP端口相同！"
                    continue
                fi
                ONEBOT_WS_PORT="$port"
                ENABLE_ONEBOT_WS="true"
            else
                if [ "$ONEBOT_WS_PORT" == "$port" ]; then
                    echo "错误：HTTP端口不能与WS端口相同！"
                    continue
                fi
                ONEBOT_HTTP_PORT="$port"
                ENABLE_ONEBOT_HTTP="true"
            fi
            SERVICE_PORTS["$port"]=1
            ;;
        2|4)
            # 反向服务
            if [ "$choice" == "2" ]; then
              read -p "Url 如 ws://host.docker.internal:8080/onebot/v11/ws）: " url
              url=${url////\/}
              if [ "$ONEBOT_WS_URLS" == "[" ]; then
                url="\"$url\""
              else
                url=",\"$url\""
              fi
              ONEBOT_WS_URLS+="$url"
            else
              read -p "Url 如 http://host.docker.internal:8080/onebot/v11/）: " url
              if [ "$ONEBOT_HTTP_URLS" == "[" ]; then
                url="\"$url\""
              else
                url=",\"$url\""
              fi
              ONEBOT_HTTP_URLS+="$url"
            fi
            ;;
        5)
            read -p "Secret:" ONEBOT_SECRET
            ;;
        6)
            read -p "Token:" ONEBOT_TOKEN
            ;;
        7)
            while true; do
                read -p "Satori port: " port
                [[ "$port" =~ ^[0-9]+$ ]] || { echo "错误：端口必须是数字！"; continue; }
                SATORI_PORT=${port}
                break
            done
            SERVICE_PORTS["$SATORI_PORT"]=1
            ENABLE_SATORI="true"
            ;;
        8)
            read -p "Satori token: " SATORI_TOKEN
            ;;
        9)
            while true; do
                read -p "WebUI 端口: " port
                [[ "$port" =~ ^[0-9]+$ ]] || { echo "错误：端口必须是数字！"; continue; }
                WEBUI_PORT=${port}
                break
            done
            SERVICE_PORTS["$WEBUI_PORT"]=1
            ENABLE_WEBUI="true"
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
    ports:
      - "${NOVNC_PORT}:6080"
    environment:
      - VNC_PASSWORD=${VNC_PASSWORD}
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
      - ENABLE_ONEBOT_WS=${ENABLE_ONEBOT_WS}
      - ENABLE_ONEBOT_HTTP=${ENABLE_ONEBOT_HTTP}
      - ONEBOT_WS_PORT=${ONEBOT_WS_PORT}
      - ONEBOT_HTTP_PORT=${ONEBOT_HTTP_PORT}
      - ONEBOT_WS_URLS=${ONEBOT_WS_URLS}
      - ONEBOT_HTTP_URLS=${ONEBOT_HTTP_URLS}
      - ONEBOT_TOKEN=${ONEBOT_TOKEN}
      - ONEBOT_SECRET=${ONEBOT_SECRET}
      - ENABLE_SATORI=${ENABLE_SATORI}
      - SATORI_PORT=${SATORI_PORT}
      - SATORI_TOKEN=${SATORI_TOKEN}
      - ENABLE_WEBUI=${ENABLE_WEBUI}
      - WEBUI_PORT=${WEBUI_PORT}

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

# 检查root权限
if [ "$(id -u)" -ne 0 ]; then
    echo "没有 root 权限，请手动运行 sudo docker compose up -d"
    echo "之后浏览器打开 http://localhost:${NOVNC_PORT}/vnc.html 访问 noVNC 登录QQ即可"
    exit 1
fi
docker compose up -d

echo "浏览器打开 http://localhost:${NOVNC_PORT}/vnc.html 访问 noVNC 登录QQ即可"
