# ASTRID - Packetbeat
# author: Alex Carrega <alessandro.carrega@cnit.it>

# Stage Get Source
FROM ubuntu:latest as get-source

# Args
ARG COMPONENT=packetbeat
ARG VERSION=7.13.4
ARG INSTALLATION_PATH=/opt/$COMPONENT
ARG TMP_PATH=/tmp
ARG SOURCE=$COMPONENT-$VERSION-linux-x86_64
ARG FILE=$SOURCE.tar.gz

# Component execution deps
RUN apt update
RUN apt install -y wget

# Download
RUN wget --no-check-certificate -P $TMP_PATH/ https://artifacts.elastic.co/downloads/beats/$COMPONENT/$FILE
RUN tar xzvf $TMP_PATH/$FILE -C $TMP_PATH/
RUN mv $TMP_PATH/$SOURCE $INSTALLATION_PATH
RUN rm $TMP_PATH/$FILE

# Stage FINAL
FROM ubuntu:latest as final

# Args
ARG COMPONENT=packetbeat
ARG VERSION=7.13.4
ARG INSTALLATION_PATH=/opt/$COMPONENT
ARG TMP_PATH=/tmp
ARG SOURCE=$COMPONENT-$VERSION-linux-x86_64
ARG FILE=$SOURCE.tar.gz

# Label
LABEL maintainer="alessandro.carrega@cnit.it"
LABEL description="$COMPONENT image based on Ubuntu"
LABEL version=$VERSION

# Variables
ENV COMPONENT=$COMPONENT
ENV VERSION=$VERSION
ENV INSTALLATION_PATH=$INSTALLATION_PATH

ENV ELASTICSEARCH_MONITORING_ENABLED=false
ENV ELASTICSEARCH_HOSTS=localhost:9200
ENV LOGSTASH_HOSTS=localhost:5044

# Settings
COPY --from=get-source $INSTALLATION_PATH $INSTALLATION_PATH
COPY settings/$VERSION/$COMPONENT.yml $INSTALLATION_PATH/

# Execute
WORKDIR $INSTALLATION_PATH
ENTRYPOINT [ "/opt/packetbeat/packetbeat" ]
