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

COPY --from=git-clone /output $GOPATH/src/gitlab.com/$PROJECT-repositories/$COMPONENT

WORKDIR $GOPATH/src/gitlab.com/$PROJECT-repositories/$COMPONENT

RUN apk add --no-cache --virtual .build-deps gcc musl-dev bash make
RUN bash build.sh
RUN mkdir $INSTALLATION_PATH
RUN cp $COMPONENT $INSTALLATION_PATH

# Stage FINAL
FROM alpine as final

ARG COMPONENT=cubebeat
ARG VERSION=master
ARG INSTALLATION_PATH=/opt/$COMPONENT

LABEL maintainer="alessandro.carrega@cnit.it"
LABEL description="Cubebeat built with Golang version 1.14.6 on Alpine Linux version 3.12"
LABEL version=$VERSION

# Variables
ENV LOGSTASH_HOSTS=localhost:5044

# Settings
COPY --from=build /output $INSTALLATION_PATH
COPY settings/$VERSION/cubebeat.yml $INSTALLATION_PATH

# Execute
WORKDIR $INSTALLATION_PATH
ENTRYPOINT ["./$COMPONENT"]
