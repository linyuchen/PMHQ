version="3.0.0"
docker buildx build --progress=plain --platform linux/amd64,linux/arm64 -t "linyuchen/pmhq:$version" -t "linyuchen/pmhq:latest" -f docker/pmhq/Dockerfile --push .