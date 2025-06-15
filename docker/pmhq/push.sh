version="2.0.1"
docker buildx build --progress=plain --platform linux/amd64,linux/arm64 -t "linyuchen/pmhq:$version" -t "linyuchen/pmhq:latest" -f docker/pmhq/Dockerfile --push .