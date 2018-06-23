FROM ubuntu:bionic as grafana_builder
RUN apt-get update -y && apt-get install -y --no-install-recommends golang git-sh nodejs npm phantomjs build-essential ca-certificates ruby ruby-dev && rm -rf /var/lib/apt/lists/* 

ENV GOPATH /usr/local/src/grafana
WORKDIR ${GOPATH}/src/github.com/grafana/
RUN git clone -v https://github.com/grafana/grafana.git

# Build backend
WORKDIR ${GOPATH}/src/github.com/grafana/grafana
RUN go run build.go setup && go run build.go build

# Build frontend
RUN npm install -g yarn
ENV DEBIAN_FRONTEND noninteractive
RUN gem install fpm
ENV QT_QPA_PLATFORM offscreen
RUN yarn install --pure-lockfile

# Build .deb
RUN go run build.go -includeBuildNumber=false pkg-deb

# Install the pR0Ps/grafana-trackmap-panel plugin
WORKDIR /var/lib/grafana-plugins
RUN git clone https://github.com/pR0Ps/grafana-trackmap-panel.git grafana-trackmap-panel
WORKDIR /var/lib/grafana-plugins/grafana-trackmap-panel
RUN npm install findup-sync && npm install grunt-cli && npm install && npm run build && npm run build && chown -R 472 /var/lib/grafana-plugins/grafana-trackmap-panel

#################

FROM ubuntu:bionic

ARG GF_UID="472"
ARG GF_GID="472"

ENV PATH=/usr/share/grafana/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    GF_PATHS_CONFIG="/etc/grafana/grafana.ini" \
    GF_PATHS_DATA="/var/lib/grafana" \
    GF_PATHS_HOME="/usr/share/grafana" \
    GF_PATHS_LOGS="/var/log/grafana" \
    GF_PATHS_PLUGINS="/var/lib/grafana-plugins" \
    GF_PATHS_PROVISIONING="/etc/grafana/provisioning"

RUN apt-get update -y && apt-get install -y tar libfontconfig curl ca-certificates &&  rm -rf /var/lib/apt/lists/* 
RUN mkdir -p "$GF_PATHS_HOME/.aws"

WORKDIR /grafana_install
COPY --from=grafana_builder /usr/local/src/grafana/src/github.com/grafana/grafana/dist/*.tar.gz .
RUN tar xfvz *.tar.gz --strip-components=1 -C "$GF_PATHS_HOME" && groupadd -r -g $GF_GID grafana && useradd -r -u $GF_UID -g grafana grafana && mkdir -p "$GF_PATHS_PROVISIONING/datasources" \
             "$GF_PATHS_PROVISIONING/dashboards" \
             "$GF_PATHS_LOGS" \
             "$GF_PATHS_PLUGINS" \
             "$GF_PATHS_DATA" && cp -v ${GF_PATHS_HOME}/conf/sample.ini ${GF_PATHS_CONFIG} && cp -v ${GF_PATHS_HOME}/conf/ldap.toml /etc/grafana/ldap.toml

# Copy plugins
COPY --from=grafana_builder /var/lib/grafana-plugins/grafana-trackmap-panel ${GF_PATHS_PLUGINS}/grafana-trackmap-panel

# Fix permissions
RUN chown -R grafana:grafana "$GF_PATHS_DATA" "$GF_PATHS_HOME/.aws" "$GF_PATHS_LOGS" "$GF_PATHS_PLUGINS" && chmod 777 "$GF_PATHS_DATA" "$GF_PATHS_HOME/.aws" "$GF_PATHS_LOGS" "$GF_PATHS_PLUGINS"

EXPOSE 3000

COPY --from=grafana/grafana:latest ./run.sh /run.sh

WORKDIR /
RUN rm -rf /grafana_install

USER grafana

ENTRYPOINT [ "/run.sh" ]
