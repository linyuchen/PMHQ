$version = "5.0.2"

docker build -t linyuchen/llonebot:amd64-$version -f docker/llonebot/Dockerfile .
docker build -t linyuchen/llonebot:arm64-$version -f docker/llonebot/Dockerfile --platform linux/arm64 .
docker push linyuchen/llonebot:amd64-$version
docker push linyuchen/llonebot:arm64-$version

# 创建多架构清单
docker manifest create `
  "linyuchen/llonebot:$version" `
  --amend "linyuchen/llonebot:amd64-$version" `
  --amend "linyuchen/llonebot:arm64-$version"

# 添加 AMD64 架构注释
docker manifest annotate `
  "linyuchen/llonebot:$version" `
  "linyuchen/llonebot:amd64-$version" `
  --os "linux" `
  --arch "amd64"

# 添加 ARM64 架构注释
docker manifest annotate `
  "linyuchen/llonebot:$version" `
  "linyuchen/llonebot:arm64-$version" `
  --os "linux" `
  --arch "arm64"

# 推送清单到仓库
docker manifest push "linyuchen/llonebot:$version"


# 为 latest 标签创建 Manifest，明确引用各架构镜像
docker manifest create `
  "linyuchen/llonebot:latest" `
  --amend "linyuchen/llonebot:amd64-$version" `
  --amend "linyuchen/llonebot:arm64-$version"

docker manifest annotate `
  "linyuchen/llonebot:latest" `
  "linyuchen/llonebot:amd64-$version" `
  --os "linux" `
  --arch "amd64"

docker manifest annotate `
  "linyuchen/llonebot:latest" `
  "linyuchen/llonebot:arm64-$version" `
  --os "linux" `
  --arch "arm64"

docker manifest push --purge "linyuchen/llonebot:latest"