# livehouseautomation/veraflux-grafana
Livehouse Automation version of Grafana Docker Image.

This image is designed to be the main visualisation tool for the VeraFlux environment, working alongside:
 * VeraFlux (for data collection): https://github.com/livehouse-automation/veraflux
 * InfluxDB (to hold the time-series data)
 * VeraFlux-Grafana (to visualise the collected data): https://hub.docker.com/r/livehouseautomation/veraflux-grafana/
 
Having said that, it will work just fine visualising whatever data you want. Go nuts. Life is too short for rules.


## Changes from the official image (grafana/grafana) ## 
 * Includes the excellent pR0Ps/grafana-trackmap-panel plugin (for showing VeraFlux 'urn:upnp-org:serviceId:IPhoneLocator1' location data)
 * Separates plugin directory from data directory


## Up-and-Running

Start the docker container:

```
docker run \
 -d \
 --restart=always \
 --name grafana \
 -p 3000:3000 \
 -v </path/to/grafana/datadir>:/var/lib/grafana \
 livehouseautomation/veraflux-grafana
```

For example, assuming the grafana data is stored at ```/opt/docker-grafana/data```:

```
docker run \
 -d \
 --restart=always \
 --name grafana \
 -p 3000:3000 \
 -v /opt/docker-grafana/data:/var/lib/grafana \
 livehouseautomation/veraflux-grafana
```

You can then hit the web interface at ```http://<host>:3000/```


## Volumes

There are no implicit volumes, however the following paths could be mapped to persistent storage depending on your requirements:
 * ```/var/lib/grafana``` at the very minimum, this path should be stored on persistent storage, otherwise when the container is removed and recreated you will lose your dashboards.
 * ```/etc/grafana``` contains the grafana configuration. If you wanted to do something non-standard (such as configure LDAP for authentication), you could map this volume.
 * ```/var/lib/grafana-plugins``` contains the grafana plugins. If you wanted to install non-standard/custom plugins, you could map this volume.


## Configuration

All options defined in conf/grafana.ini can be overridden using environment variables by using the syntax GF_<SectionName>_<KeyName>.

More information on this is available in the official package documentation:
 * http://docs.grafana.org/installation/docker/#configuration
 * http://docs.grafana.org/installation/docker/#reading-secrets-from-files-support-for-docker-secrets
  

## Installing additional official plugins

Additional official plugins can be installed using the ```GF_INSTALL_PLUGINS``` environment variable, for example:

```
docker run \
 -d \
 --restart=always \
 --name grafana \
 -p 3000:3000 \
 -v /opt/docker-grafana/data:/var/lib/grafana \
 -e GF_INSTALL_PLUGINS=grafana-clock-panel \
 livehouseautomation/veraflux-grafana
```

More information on this is available in the official package documentation: http://docs.grafana.org/installation/docker/#installing-plugins-for-grafana


## Ports

The following ports are used by this container:

* `3000` - Grafana web interface
