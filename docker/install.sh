#!/bin/bash

# 检查root权限
if [ "$(id -u)" -ne 0 ]; then
    echo "请使用 sudo 运行此脚本！"
    exit 1
fi

# 安装docker依赖
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

# 初始化配置变量
IMPLEMENTATIONS_STR="[]"
declare -A SERVICE_PORTS

# JSON构建函数（全手动转义）
function build_escaped_json() {
    local type=$1 host=$2 port=$3 token=$4 suffix=$5 secret=$6
    local json="{"
    json+="\"Type\":\"$type\","
    json+="\"Host\":\"$host\","
    json+="\"Port\":$port"

    # 可选字段处理
    [ -n "$token" ] && json+=",\"AccessToken\":\"$token\""
    [ -n "$suffix" ] && json+=",\"Suffix\":\"$suffix\""
    [ -n "$secret" ] && json+=",\"Secret\":\"$secret\""

    # 类型特定字段
    case $type in
        "ForwardWebSocket")
            json+=",\"HeartBeatInterval\":30000,\"HeartBeatEnable\":true" ;;
        "ReverseWebSocket")
            json+=",\"ReconnectInterval\":5000,\"HeartBeatInterval\":30000" ;;
        "HttpPost")
            json+=",\"HeartBeatInterval\":30000,\"HeartBeatEnable\":true" ;;
    esac

    json+="}"
    echo "$json"
}

# 交互式配置
while :; do
    clear
    echo "------------------------"
    echo "请选择 OneBot V11 服务类型："
    echo "1) 添加正向WS"
    echo "2) 添加反向WS"
    echo "3) 添加HTTP服务"
    echo "4) 添加HTTP上报"
    echo "0) 完成配置"
    read -p "输入选项 (0-4): " choice

    case $choice in
        0)
            break ;;
        1|3)
            # 正向WS/HTTP服务
            host="*"
            port=""
            token=""

            # 端口验证
            while true; do
                read -p "Port（默认8080）: " port
                port=${port:-8080}
                [[ "$port" =~ ^[0-9]+$ ]] || { echo "错误：端口必须是数字！"; continue; }
                [[ -n "${SERVICE_PORTS[$port]}" ]] && { echo "错误：端口 $port 已被使用！"; continue; }
                break
            done

            SERVICE_PORTS["$port"]=1
            read -p "Token（可选）: " token

            # 构建JSON
            type=$([ "$choice" -eq 1 ] && echo "ForwardWebSocket" || echo "Http")
            new_json=$(build_escaped_json "$type" "$host" "$port" "$token")

            # 更新数组
            if [ "$IMPLEMENTATIONS_STR" = "[]" ]; then
                IMPLEMENTATIONS_STR="[${new_json}]"
            else
                IMPLEMENTATIONS_STR=$(echo "$IMPLEMENTATIONS_STR" | sed "s/\]\$/,${new_json}]/")
            fi
            ;;
        2|4)
            # 反向服务
            host=""
            port=""
            suffix="/"
            token=""
            secret=""

            while [ -z "$host" ]; do
                read -p "Host（默认host.docker.internal）: " host
                host=${host:-host.docker.internal}
            done

            while true; do
                read -p "Port（默认8080）: " port
                port=${port:-8080}
                [[ "$port" =~ ^[0-9]+$ ]] && break
                echo "错误：端口必须是数字！"
            done

            read -p "Url Path（如 /onebot/v11/）: " suffix
            [ "$choice" -eq 4 ] && read -p "Secret（可选）: " secret
            read -p "Token（可选）: " token

            # 构建JSON
            type=$([ "$choice" -eq 2 ] && echo "ReverseWebSocket" || echo "HttpPost")
            new_json=$(build_escaped_json "$type" "$host" "$port" "$token" "$suffix" "$secret")

            # 更新数组
            if [ "$IMPLEMENTATIONS_STR" = "[]" ]; then
                IMPLEMENTATIONS_STR="[${new_json}]"
            else
                IMPLEMENTATIONS_STR=$(echo "$IMPLEMENTATIONS_STR" | sed "s/\]\$/,${new_json}]/")
            fi
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

  lagrange.onebot.pmhq:
    image: ${docker_mirror}linyuchen/lagrange.onebot.pmhq:latest
$([ ${#SERVICE_PORTS[@]} -gt 0 ] && echo "    ports:" && for port in "${!SERVICE_PORTS[@]}"; do echo "      - \"${port}:${port}\""; done)
    environment:
      - ONEBOT_SERVICES=$IMPLEMENTATIONS_STR
    networks:
      - app_network
    depends_on:
      - pmhq

networks:
  app_network:
    driver: bridge
EOF

docker compose up -d

echo "浏览器打开 http://localhost:${NOVNC_PORT}/vnc.html 访问 noVNC 登录QQ即可"