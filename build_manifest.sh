docker manifest create livehouseautomation/veraflux-grafana:latest livehouseautomation/veraflux-grafana:v5.1.x-arm7l livehouseautomation/veraflux-grafana:v5.1.x-x86_64
docker manifest annotate livehouseautomation/veraflux-grafana:latest livehouseautomation/veraflux-grafana:v5.1.x-x86_64 --os linux --arch amd64
docker manifest annotate livehouseautomation/veraflux-grafana:latest livehouseautomation/veraflux-grafana:v5.1.x-arm7l --os linux --arch arm --variant v7
docker manifest push livehouseautomation/veraflux-grafana:latest
