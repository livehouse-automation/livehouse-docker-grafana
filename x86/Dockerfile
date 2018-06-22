FROM grafana/grafana
  
# Install prerequisites
USER root
RUN apt-get update -y && apt-get install -y --no-install-recommends git gnupg gcc g++ make && rm -rf /var/lib/apt/lists/*

# Install NPM (prerequisite for plugins)
WORKDIR /usr/local/src/nodejs
RUN curl -sL https://deb.nodesource.com/setup_9.x | bash - && apt-get install -y --no-install-recommends nodejs && rm -rf /var/lib/apt/lists/* && rm -rf /usr/local/src/nodejs/*

# Install Grunt (prerequisite for plugins)
RUN npm install -g grunt-cli

# Separate plugins area out from dashboard storage
RUN mv -v /var/lib/grafana/plugins /var/lib/grafana-plugins
ENV GF_PATHS_PLUGINS /var/lib/grafana-plugins

# Install the pR0Ps/grafana-trackmap-panel plugin
WORKDIR /var/lib/grafana-plugins
RUN git clone https://github.com/pR0Ps/grafana-trackmap-panel.git grafana-trackmap-panel
WORKDIR /var/lib/grafana-plugins/grafana-trackmap-panel
RUN npm install findup-sync && npm install grunt-cli && npm install && npm run build && npm run build && chown -R 472 /var/lib/grafana-plugins/grafana-trackmap-panel

# Clean up
RUN apt-get remove -y git gnupg gcc g++ make && rm -rf /usr/local/src/* && apt-get autoremove -y && apt-get purge -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

USER grafana
WORKDIR /
