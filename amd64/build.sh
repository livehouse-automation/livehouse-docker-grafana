#!/bin/bash

ARCH="amd64"
IMAGENAME="livehouseautomation/veraflux-grafana"
TAG="l"

echo "BUILDING $ARCH"
docker build -t $IMAGENAME:$TAG-$ARCH .
