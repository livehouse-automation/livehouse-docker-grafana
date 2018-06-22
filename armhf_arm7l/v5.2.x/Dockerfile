##############################################
### Multi-stage build file for grafana on ARM platform
### "grafana_builder" stage to build grafana from source on ARM
### final stage as-per grafana/grafana-docker with minor alteration to copy grafana from "grafana_builder" stage instead of fetching with curl
##############################################

FROM ubuntu:bionic as grafana_builder
RUN apt-get update -y

### BUILDING GRAFANA (doing this in a container)
### as-per http://docs.grafana.org/project/building_from_source/

# Install dependencies

# Go 1.10
RUN apt-get install -y --no-install-recommends golang

# Git
RUN apt-get install -y --no-install-recommends git-sh

# NodeJS LTS
RUN apt-get install -y --no-install-recommends nodejs
RUN apt-get install -y --no-install-recommends npm
RUN apt-get install -y --no-install-recommends phantomjs

# Build Essential
RUN apt-get install -y --no-install-recommends build-essential

# Get grafana source
RUN apt-get install -y --no-install-recommends ca-certificates
ENV GOPATH /usr/local/src/grafana
WORKDIR ${GOPATH}/src/github.com/grafana/
#RUN go get -v github.com/grafana/grafana <-- has issues and throws warnings, using git clone instead
RUN git clone -v https://github.com/grafana/grafana.git

# Build backend
WORKDIR ${GOPATH}/src/github.com/grafana/grafana
RUN go run build.go setup
RUN go run build.go build

# Build frontend
RUN npm install -g yarn
ENV DEBIAN_FRONTEND noninteractive
#RUN apt-get install -y --no-install-recommends lubuntu-desktop
RUN apt-get install -y --no-install-recommends ruby ruby-dev
RUN gem install fpm
ENV QT_QPA_PLATFORM offscreen
RUN yarn install --pure-lockfile

# Build .deb
RUN go run build.go -includeBuildNumber=false pkg-deb

#################

FROM ubuntu:bionic

# Note: Original grafana image uses FROM debian:stretch-slim.
# We can't use that, as it used obsolete and binary incompatible armel.
# Ubuntu has adopted newer & better (IMHO) armhf.

ARG GF_UID="472"
ARG GF_GID="472"

ENV PATH=/usr/share/grafana/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    GF_PATHS_CONFIG="/etc/grafana/grafana.ini" \
    GF_PATHS_DATA="/var/lib/grafana" \
    GF_PATHS_HOME="/usr/share/grafana" \
    GF_PATHS_LOGS="/var/log/grafana" \
    GF_PATHS_PLUGINS="/var/lib/grafana-plugins" \
    GF_PATHS_PROVISIONING="/etc/grafana-provisioning"

RUN apt-get update -y 
RUN apt-get install -y tar libfontconfig curl ca-certificates
RUN mkdir -p "$GF_PATHS_HOME/.aws"

WORKDIR /grafana_install
COPY --from=grafana_builder /usr/local/src/grafana/src/github.com/grafana/grafana/dist/*.tar.gz .
RUN tar xfvz *.tar.gz --strip-components=1 -C "$GF_PATHS_HOME"

RUN apt-get autoremove -y
RUN rm -rf /var/lib/apt/lists/*
RUN groupadd -r -g $GF_GID grafana
RUN useradd -r -u $GF_UID -g grafana grafana
RUN mkdir -p "$GF_PATHS_PROVISIONING/datasources" \
             "$GF_PATHS_PROVISIONING/dashboards" \
             "$GF_PATHS_LOGS" \
             "$GF_PATHS_PLUGINS" \
             "$GF_PATHS_DATA"
RUN cp "$GF_PATHS_HOME/conf/sample.ini" "$GF_PATHS_CONFIG"
RUN cp "$GF_PATHS_HOME/conf/ldap.toml" /etc/grafana/ldap.toml
RUN chown -R grafana:grafana "$GF_PATHS_DATA" "$GF_PATHS_HOME/.aws" "$GF_PATHS_LOGS" "$GF_PATHS_PLUGINS"
RUN chmod 777 "$GF_PATHS_DATA" "$GF_PATHS_HOME/.aws" "$GF_PATHS_LOGS" "$GF_PATHS_PLUGINS"

EXPOSE 3000

COPY --from=grafana/grafana:latest ./run.sh /run.sh

USER grafana
WORKDIR /
RUN rm -rf /grafana_install

ENTRYPOINT [ "/run.sh" ]
