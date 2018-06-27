#
# Docker architectures
# https://github.com/docker-library/official-images/blob/a7ad3081aa5f51584653073424217e461b72670a/bashbrew/go/vendor/src/github.com/docker-library/go-dockerlibrary/architecture/oci-platform.go#L14-L25
#
docker manifest create livehouseautomation/veraflux-grafana:latest livehouseautomation/veraflux-grafana:v5.1.x-arm7l livehouseautomation/veraflux-grafana:v5.1.x-x86_64
docker manifest annotate livehouseautomation/veraflux-grafana:latest livehouseautomation/veraflux-grafana:v5.1.x-x86_64 --os linux --arch amd64
docker manifest annotate livehouseautomation/veraflux-grafana:latest livehouseautomation/veraflux-grafana:v5.1.x-arm7l --os linux --arch arm --variant v7
docker manifest push livehouseautomation/veraflux-grafana:latest
