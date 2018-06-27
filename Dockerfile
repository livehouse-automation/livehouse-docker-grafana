####################################################################
# Multi-stage build for grafana
# 
# First container (grafana_builder) builds grafana and all plugins
# Second container is the actual image
#
####################################################################
# First build stage
#####

FROM ubuntu:bionic as grafana_builder

# Install the many build pre-requisites
RUN apt-get update -y && \
    apt-get install -y golang git-sh nodejs npm phantomjs build-essential ca-certificates ruby ruby-dev curl && \
    rm -rf /var/lib/apt/lists/* 

# Set up Go build environment for grafana
ENV GOPATH /usr/local/src/grafana
WORKDIR ${GOPATH}/src/github.com/grafana/

# Clone grafana sources
RUN git clone -v -b v5.1.x https://github.com/grafana/grafana.git

# Build grafana backend
WORKDIR ${GOPATH}/src/github.com/grafana/grafana
RUN go run build.go setup && go run build.go build

# Build grafana frontend
RUN npm install -g yarn
ENV DEBIAN_FRONTEND noninteractive
RUN gem install fpm
ENV QT_QPA_PLATFORM offscreen
RUN yarn install --pure-lockfile

# Build grafana .deb for installation in second build phase
RUN go run build.go -includeBuildNumber=false pkg-deb

# Build grafana plugin: pR0Ps/grafana-trackmap-panel
WORKDIR /var/lib/grafana-plugins
RUN git clone https://github.com/pR0Ps/grafana-trackmap-panel.git grafana-trackmap-panel
WORKDIR /var/lib/grafana-plugins/grafana-trackmap-panel
RUN npm install findup-sync && \
    npm install grunt-cli && \
    npm install && \
    npm run build && \
    npm run build && \
    chown -R 472 /var/lib/grafana-plugins/grafana-trackmap-panel

####################################################################
# Second build stage
#####

FROM ubuntu:bionic

# Define volumes (data, config, plugins)
VOLUME ["/var/lib/grafana", "/etc/grafana", "/var/lib/grafana-plugins"]

# Expose grafana port
EXPOSE 3000/tcp

# Set up UID/GID for grafana
ARG GF_UID="472"
ARG GF_GID="472"

# Set environment variables
ENV PATH=/usr/share/grafana/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    GF_PATHS_CONFIG="/etc/grafana/grafana.ini" \
    GF_PATHS_DATA="/var/lib/grafana" \
    GF_PATHS_HOME="/usr/share/grafana" \
    GF_PATHS_LOGS="/var/log/grafana" \
    GF_PATHS_PLUGINS="/var/lib/grafana-plugins" \
    GF_PATHS_PROVISIONING="/etc/grafana/provisioning"

# Install prerequisites
RUN apt-get update -y && apt-get install -y tar libfontconfig curl ca-certificates &&  rm -rf /var/lib/apt/lists/* 

# Set up directory structure & copy pre-built grafana from previous build stage
WORKDIR /grafana_install
COPY --from=grafana_builder /usr/local/src/grafana/src/github.com/grafana/grafana/dist/*.tar.gz .
RUN mkdir -p "$GF_PATHS_HOME/.aws" && \
    cd /grafana_install && \
    tar xfvz *.tar.gz --strip-components=1 -C "$GF_PATHS_HOME" && \
    groupadd -r -g $GF_GID grafana && \
    useradd -r -u $GF_UID -g grafana grafana && \
    mkdir -p "$GF_PATHS_PROVISIONING/datasources" \
             "$GF_PATHS_PROVISIONING/dashboards" \
             "$GF_PATHS_LOGS" \
             "$GF_PATHS_PLUGINS" \
             "$GF_PATHS_DATA" && \
    cp -v ${GF_PATHS_HOME}/conf/sample.ini ${GF_PATHS_CONFIG} && \
    cp -v ${GF_PATHS_HOME}/conf/ldap.toml /etc/grafana/ldap.toml

# Copy pre-built pR0Ps/grafana-trackmap-panel from previous build stage
COPY --from=grafana_builder /var/lib/grafana-plugins/grafana-trackmap-panel ${GF_PATHS_PLUGINS}/grafana-trackmap-panel

# Fix permissions, remove temp install directory
RUN chown -R grafana:grafana "$GF_PATHS_DATA" "$GF_PATHS_HOME/.aws" "$GF_PATHS_LOGS" "$GF_PATHS_PLUGINS" && \
    chmod 777 "$GF_PATHS_DATA" "$GF_PATHS_HOME/.aws" "$GF_PATHS_LOGS" "$GF_PATHS_PLUGINS" && \
    rm -rf /grafana_install

# Copy entrypoint from grafana/grafana image, set user and set entrypoint
COPY --from=grafana/grafana:latest /run.sh /run.sh
USER grafana
ENTRYPOINT ["/run.sh"]
