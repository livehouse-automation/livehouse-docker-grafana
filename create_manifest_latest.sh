#!/bin/bash

echo "CREATE MULTI-ARCH DOCKER MANIFEST"

IMAGENAME="livehouseautomation/veraflux-grafana"
TAG="5.1.5"

docker manifest create $IMAGENAME:latest $IMAGENAME:$TAG-arm32v7 $IMAGENAME:$TAG-amd64
docker manifest annotate $IMAGENAME:latest $IMAGENAME:$TAG-amd64 --os linux --arch amd64
docker manifest annotate $IMAGENAME:latest $IMAGENAME:$TAG-arm32v7 --os linux --arch arm --variant v7
docker manifest push $IMAGENAME:latest
