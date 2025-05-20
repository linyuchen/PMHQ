export DOCKER_CLI_EXPERIMENTAL=enabled

docker manifest create linyuchen/lagrange.onebot.pmhq:latest --amend linyuchen/lagrange.onebot.pmhq:latest --amend linyuchen/lagrange.onebot.pmhq:latest-arm64

docker manifest annotate linyuchen/lagrange.onebot.pmhq:latest linyuchen/lagrange.onebot.pmhq:latest --os linux --arch amd64

docker manifest annotate linyuchen/lagrange.onebot.pmhq:latest linyuchen/lagrange.onebot.pmhq:latest-arm64 --os linux --arch arm64

docker manifest push linyuchen/lagrange.onebot.pmhq:latest