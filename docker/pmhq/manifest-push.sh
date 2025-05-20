export DOCKER_CLI_EXPERIMENTAL=enabled

docker manifest create linyuchen/pmhq:latest --amend linyuchen/pmhq:latest --amend linyuchen/pmhq:latest-arm64

docker manifest annotate linyuchen/pmhq:latest linyuchen/pmhq:latest --os linux --arch amd64

docker manifest annotate linyuchen/pmhq:latest linyuchen/pmhq:latest-arm64 --os linux --arch arm64

docker manifest push linyuchen/pmhq:latest