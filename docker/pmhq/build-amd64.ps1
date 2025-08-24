$version="2.4.0"
docker build --build-arg PMHQ_VERSION=$version --progress=plain --platform linux/amd64 -t "linyuchen/pmhq:$version" -t "linyuchen/pmhq:latest" -f docker/pmhq/Dockerfile .