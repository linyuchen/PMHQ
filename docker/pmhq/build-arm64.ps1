$version="2.1.1"
docker build --build-arg PMHQ_VERSION=$version --progress=plain --platform linux/arm64 -t "linyuchen/pmhq:$version" -t "linyuchen/pmhq:latest" -f docker/pmhq/Dockerfile .