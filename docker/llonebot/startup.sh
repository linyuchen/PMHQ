#!/bin/ash

cd /app/llonebot

if [ -n "$pmhq_port" ]; then
    node ./llonebot.js --pmhq-port=$pmhq_port
else
    node ./llonebot.js
fi