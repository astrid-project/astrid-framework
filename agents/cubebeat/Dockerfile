# ASTRID - Cubebeat
# author: Alex Carrega <alessandro.carrega@cnit.it>

# Stage GIT CLONE
FROM alpine/git as git-clone

ARG COMPONENT=cubebeat
ARG VERSION=master
ARG PROJECT=astrid
ARG INSTALLATION_PATH=/opt/$COMPONENT

RUN git clone https://github.com/$PROJECT-project/$COMPONENT --branch $VERSION $INSTALLATION_PATH


# Stage FINAL
FROM golang:1.14.6-alpine3.12 as build

ARG COMPONENT=cubebeat
ARG PROJECT=astrid
ARG INSTALLATION_PATH=/opt/$COMPONENT

ENV GOPATH=/opt/go

RUN apk add --no-cache --virtual .build-deps gcc musl-dev bash make

COPY --from=git-clone $INSTALLATION_PATH $GOPATH/src/gitlab.com/$PROJECT-repositories/$COMPONENT

WORKDIR $GOPATH/src/gitlab.com/$PROJECT-repositories/$COMPONENT

RUN bash +x build.sh
RUN mkdir -p $INSTALLATION_PATH
COPY $COMPONENT $INSTALLATION_PATH/

# Stage FINAL
FROM alpine as final

ARG COMPONENT=cubebeat
ARG VERSION=master
ARG INSTALLATION_PATH=/opt/$COMPONENT

LABEL maintainer="alessandro.carrega@cnit.it"
LABEL description="Cubebeat built with Golang version 1.14.6 on Alpine Linux version 3.12"
LABEL version=$VERSION

# Variables
ENV ELASTICSEARCH_HOSTS=localhost:9200
ENV ELASTICSEARCH_MONITORING_ENABLED=false
ENV LOGSTASH_HOSTS=localhost:5044

# Settings
COPY --from=build $INSTALLATION_PATH $INSTALLATION_PATH
COPY settings/$VERSION/cubebeat.yml $INSTALLATION_PATH/

# Execute
WORKDIR $INSTALLATION_PATH
ENTRYPOINT [ "./$COMPONENT" ]
