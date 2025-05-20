#!/bin/bash

CONFIG_FILE="/app/appsettings.json"

if [ -n "$ONEBOT_SERVICES" ]; then
    echo "正在更新 Implementations 配置..."

    # 解码JSON字符串
    echo "$ONEBOT_SERVICES"
    CLEAN_JSON=$(echo "$ONEBOT_SERVICES" | jq -r .)

    # 验证JSON有效性
    if ! echo "$CLEAN_JSON" | jq empty 2>/dev/null; then
        echo "错误：ONEBOT_SERVICES 包含无效JSON"
        echo "当前值：$CLEAN_JSON"
        exit 1
    fi

    # 生成临时文件
    TMP_FILE=$(mktemp)

    # 更新配置文件
    jq --argjson impls "$CLEAN_JSON" '.Implementations = $impls' "$CONFIG_FILE" > "$TMP_FILE"

    # 替换原文件
    mv "$TMP_FILE" "$CONFIG_FILE"
    echo "配置更新成功"
else
    echo "未检测到 ONEBOT_SERVICES，使用默认配置"
fi

exec /app/Lagrange.OneBot.PMHQ