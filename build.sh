#!/bin/bash

IMAGENAME="livehouseautomation/veraflux-grafana"
TAG="development-v5.1.x"

echo "GENERATING DOCKERFILES FROM Dockerfile.in"
python ./helper_scripts/generate_dockerfiles.py

# set up multiarch build env
echo "SETTING UP MULTI ARCH BUILD ENVIRONMENT"
sudo docker run --rm --privileged multiarch/qemu-user-static:register --reset

# build arm32v7
echo "BUILDING arm32v7"
cp -v COPY /usr/bin/qemu-arm-static ./arm32v7/
docker build -t $IMAGENAME:$TAG-arm32v7 ./arm32v7/
rm -v ./arm32v7/qemu-arm-static

# build amd64
echo "BUILDING amd64"
cp -v COPY /usr/bin/qemu-arm-static ./amd64/
docker build -t $IMAGENAME:$TAG-amd64 ./amd64/
rm -v ./amd64/qemu-arm-static

# Create multiarch manifest
echo "CREATE MULTI ARCH MANIFEST"
# Docker architectures
# https://github.com/docker-library/official-images/blob/a7ad3081aa5f51584653073424217e461b72670a/bashbrew/go/vendor/src/github.com/docker-library/go-dockerlibrary/architecture/oci-platform.go#L14-L25
#
docker manifest create $IMAGENAME:$TAG $IMAGENAME:$TAG-arm32v7 $IMAGENAME:$TAG-amd64
docker manifest annotate $IMAGENAME:$TAG $IMAGENAME:$TAG-amd64 --os linux --arch amd64
docker manifest annotate $IMAGENAME:$TAG $IMAGENAME:$TAG-arm32v7 --os linux --arch arm --variant v7

# push everything
echo "PUSHING IMAGES & MANIFEST TO DOCKER HUB"
docker push $IMAGENAME:$TAG-arm32v7
docker push $IMAGENAME:$TAG-amd64
docker manifest push $IMAGENAME:$TAG