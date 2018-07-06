#!/bin/bash -x

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
