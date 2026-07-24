$version="test"
docker build --build-arg PMHQ_VERSION=$version --progress=plain --platform linux/arm64 -t "linyuchen/pmhq:$version-arm" -t "linyuchen/pmhq:latest-arm" -f docker/Dockerfile.test .