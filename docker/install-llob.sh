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

TOKEN=""
SECRET=""
WS_URLS="["
HTTP_URLS="["
ENABLE_WS="false"
ENABLE_HTTP="false"
WS_PORT="3001"
HTTP_PORT="3000"
declare -A SERVICE_PORTS

# 交互式配置
while :; do
    clear
    echo "------------------------"
    echo "请选择 OneBot V11 设置："
    echo "1) 设置正向WS"
    echo "2) 添加反向WS"
    echo "3) 设置HTTP服务"
    echo "4) 添加HTTP上报"
    echo "5) 设置token"
    echo "6) 设置secret"
    echo "0) 完成配置"
    printf "输入选项 (0-6): "
    read choice # 改用不带参数的 read 兼容dash

    case $choice in
        0)
            WS_URLS+="]"
            HTTP_URLS+="]"
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

            if [ choice -eq 1 ]; then
                if [ HTTP_PORT == "$port" ]; then
                    echo "错误：WS端口不能与HTTP端口相同！"
                    continue
                fi
                WS_PORT="$port"
            else
                if [ WS_PORT == "$port" ]; then
                    echo "错误：HTTP端口不能与WS端口相同！"
                    continue
                fi
                HTTP_PORT="$port"
            fi
            SERVICE_PORTS["$port"]=1
            ;;
        2|4)
            # 反向服务
            if [ choice -eq 2 ]; then
              read -p "Url 如 ws://host.docker.internal:8080/onebot/v11/ws）: " url
              if [ WS_URLS == "[" ]; then
                url="\"$url\""
              else
                url=",\"$url\""
              fi
              WS_URLS+="$url"
            else
              read -p "Url 如 http://host.docker.internal:8080/onebot/v11/）: " url
              if [ WS_URLS == "[" ]; then
                url="\"$url\""
              else
                url=",\"$url\""
              fi
              HTTP_URLS+="$url"
            fi
            ;;
        5)
            read -p "Token:" TOKEN
            ;;
        6)
            read -p "Secret:" SECRET
            ;;
        *)
            echo "无效选项"
            ;;
    esac
done

docker_mirror=""

#read -p "是否使用docker镜像源(y/n): " use_docker_mirror
#
#if [[ "$use_docker_mirror" =~ ^[yY]$ ]]; then
#  docker_mirror="docker.1ms.run/"
#fi
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

  llonebot:
    image: ${docker_mirror}linyuchen/llonebot:latest
$([ ${#SERVICE_PORTS[@]} -gt 0 ] && echo "    ports:" && for port in "${!SERVICE_PORTS[@]}"; do echo "      - \"${port}:${port}\""; done)
    environment:
      - ENABLE_WS=${ENABLE_WS}
      - ENABLE_HTTP=${ENABLE_HTTP}
      - WS_PORT=${WS_PORT}
      - HTTP_PORT=${HTTP_PORT}
      - WS_URLS=${WS_URLS}
      - HTTP_URLS=${HTTP_URLS}
    networks:
      - app_network
    depends_on:
      - pmhq

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
