$version = "5.2.0"
docker buildx build --platform linux/amd64,linux/arm64 -t "linyuchen/llonebot:$version" -t "linyuchen/llonebot:latest" -f docker/llonebot/Dockerfile --push .