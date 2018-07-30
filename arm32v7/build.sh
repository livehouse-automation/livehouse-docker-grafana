#!/bin/bash

ARCH="arm32v7"
IMAGENAME="livehouseautomation/veraflux-grafana"
TAG="l"

echo "BUILDING $ARCH"
docker build -t $IMAGENAME:$TAG-$ARCH .
