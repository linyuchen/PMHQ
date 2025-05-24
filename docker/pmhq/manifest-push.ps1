$version = "1.0.1"

docker build -t linyuchen/pmhq:amd64-$version -f docker/pmhq/Dockerfile .
docker build -t linyuchen/pmhq:arm64-$version -f docker/pmhq/Dockerfile --platform linux/arm64 .
docker push linyuchen/pmhq:amd64-$version
docker push linyuchen/pmhq:arm64-$version

# 创建多架构清单
docker manifest create `
  "linyuchen/pmhq:$version" `
  --amend "linyuchen/pmhq:amd64-$version" `
  --amend "linyuchen/pmhq:arm64-$version"

# 添加 AMD64 架构注释
docker manifest annotate `
  "linyuchen/pmhq:$version" `
  "linyuchen/pmhq:amd64-$version" `
  --os "linux" `
  --arch "amd64"

# 添加 ARM64 架构注释
docker manifest annotate `
  "linyuchen/pmhq:$version" `
  "linyuchen/pmhq:arm64-$version" `
  --os "linux" `
  --arch "arm64"

# 推送清单到仓库
docker manifest push "linyuchen/pmhq:$version"


# 为 latest 标签创建 Manifest，明确引用各架构镜像
docker manifest create `
  "linyuchen/pmhq:latest" `
  --amend "linyuchen/pmhq:amd64-$version" `
  --amend "linyuchen/pmhq:arm64-$version"

docker manifest annotate `
  "linyuchen/pmhq:latest" `
  "linyuchen/pmhq:amd64-$version" `
  --os "linux" `
  --arch "amd64"

docker manifest annotate `
  "linyuchen/pmhq:latest" `
  "linyuchen/pmhq:arm64-$version" `
  --os "linux" `
  --arch "arm64"

docker manifest push --purge "linyuchen/pmhq:latest"