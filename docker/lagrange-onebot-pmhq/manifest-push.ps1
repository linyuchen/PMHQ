$version = "1.0.1"

docker build -t linyuchen/lagrange.onebot.pmhq:amd64-$version -f docker/lagrange-onebot-pmhq/Dockerfile .
docker build -t linyuchen/lagrange.onebot.pmhq:arm64-$version -f docker/lagrange-onebot-pmhq/Dockerfile --platform linux/arm64 .
docker push linyuchen/lagrange.onebot.pmhq:amd64-$version
docker push linyuchen/lagrange.onebot.pmhq:arm64-$version

# 为 latest 标签创建 Manifest，明确引用各架构镜像
docker manifest create `
  "linyuchen/lagrange.onebot.pmhq:latest" `
  --amend "linyuchen/lagrange.onebot.pmhq:amd64-$version" `
  --amend "linyuchen/lagrange.onebot.pmhq:arm64-$version"

docker manifest annotate `
  "linyuchen/lagrange.onebot.pmhq:latest" `
  "linyuchen/lagrange.onebot.pmhq:amd64-$version" `
  --os "linux" `
  --arch "amd64"

docker manifest annotate `
  "linyuchen/lagrange.onebot.pmhq:latest" `
  "linyuchen/lagrange.onebot.pmhq:arm64-$version" `
  --os "linux" `
  --arch "arm64"

docker manifest push --purge "linyuchen/lagrange.onebot.pmhq:latest"

# 创建多架构清单
docker manifest create `
  "linyuchen/lagrange.onebot.pmhq:$version" `
  --amend "linyuchen/lagrange.onebot.pmhq:amd64-$version" `
  --amend "linyuchen/lagrange.onebot.pmhq:arm64-$version"

# 添加 AMD64 架构注释
docker manifest annotate `
  "linyuchen/lagrange.onebot.pmhq:$version" `
  "linyuchen/lagrange.onebot.pmhq:amd64-$version" `
  --os "linux" `
  --arch "amd64"

# 添加 ARM64 架构注释
docker manifest annotate `
  "linyuchen/lagrange.onebot.pmhq:$version" `
  "linyuchen/lagrange.onebot.pmhq:arm64-$version" `
  --os "linux" `
  --arch "arm64"

# 推送清单到仓库
docker manifest push "linyuchen/lagrange.onebot.pmhq:$version"


