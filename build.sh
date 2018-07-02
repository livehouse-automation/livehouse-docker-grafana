#!/bin/bash

IMAGENAME="livehouseautomation/veraflux-grafana"
TAG="development-v5.1.x"

python ./generate_dockerfiles.py

# set up multiarch build env
docker run --rm --privileged multiarch/qemu-user-static:register

# build arm32v7
docker build -t $IMAGENAME:$TAG-arm32v7 ./arm32v7/

# build amd64
docker build -t $IMAGENAME:$TAG-amd64 ./amd64/

# Create multiarch manifest
# Docker architectures
# https://github.com/docker-library/official-images/blob/a7ad3081aa5f51584653073424217e461b72670a/bashbrew/go/vendor/src/github.com/docker-library/go-dockerlibrary/architecture/oci-platform.go#L14-L25
#
docker manifest create $IMAGENAME:$TAG $IMAGENAME:$TAG-arm32v7 $IMAGENAME:$TAG-amd64
docker manifest annotate $IMAGENAME:$TAG $IMAGENAME:$TAG-amd64 --os linux --arch amd64
docker manifest annotate $IMAGENAME:$TAG $IMAGENAME:$TAG-arm32v7 --os linux --arch arm --variant v7

# push everything
docker push $IMAGENAME:$TAG-arm32v7
docker push $IMAGENAME:$TAG-amd64
docker manifest push $IMAGENAME:$TAG