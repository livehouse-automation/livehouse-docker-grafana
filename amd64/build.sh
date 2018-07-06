
#!/bin/bash

ARCH="amd64"
IMAGENAME="livehouseautomation/veraflux-grafana"
TAG="dev-5.1.x"

echo "BUILDING $ARCH"
docker build -t $IMAGENAME:$TAG-$ARCH .
docker push $IMAGENAME:$TAG-$ARCH
		