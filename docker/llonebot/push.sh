version="5.1.0"
docker buildx build --progress=plain --platform linux/amd64,linux/arm64 -t "linyuchen/llonebot:$version" -t "linyuchen/llonebot:latest" -f docker/llonebot/Dockerfile --push .