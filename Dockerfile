FROM grafana/grafana

# Install prerequisites
USER root
RUN apt-get update -y
RUN apt-get install -y git
RUN apt-get install -y gnupg
RUN apt-get install -y gcc g++ make

# Install NPM
WORKDIR /usr/local/src/nodejs
RUN curl -sL https://deb.nodesource.com/setup_9.x | bash -
RUN apt-get install -y nodejs

# Install Grunt
RUN npm install -g grunt-cli

# Install the pR0Ps/grafana-trackmap-panel plugin
WORKDIR /var/lib/grafana-plugins
RUN git clone https://github.com/pR0Ps/grafana-trackmap-panel.git grafana-trackmap-panel
WORKDIR /var/lib/grafana-plugins/grafana-trackmap-panel
RUN npm install findup-sync
RUN npm install grunt-cli
RUN npm install
RUN npm run build

# Separate plugins area out from dashboard storage
RUN chown -R 472 /var/lib/grafana-plugins
ENV GF_PATHS_PLUGINS /var/lib/grafana-plugins

USER grafana
WORKDIR /
