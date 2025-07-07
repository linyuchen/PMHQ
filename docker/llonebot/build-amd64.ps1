$version = "5.3.0"
docker build --build-arg LLONEBOT_VERSION=$version --progress=plain --platform linux/amd64 -t linyuchen/llonebot:$version -t linyuchen/llonebot:latest -f docker/llonebot/Dockerfile .
