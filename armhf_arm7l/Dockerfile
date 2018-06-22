FROM ubuntu:xenial as grafana_builder

### NOTE: This Dockerfile is under development and as-such has not yet been optimised.
###       Suggest not using it until it has been merged into the master branch.

RUN apt-get update -y

### BUILDING GRAFANA
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
WORKDIR /usr/local/src/grafana
RUN go get -v github.com/grafana/grafana

# Build backend
WORKDIR /usr/local/src/grafana/src/github.com/grafana/grafana
RUN go run build.go setup
RUN go run build.go build
