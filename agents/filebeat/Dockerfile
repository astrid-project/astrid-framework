# Image
ARG OS_VERSION=3.12.0
FROM alpine:$OS_VERSION

# Args
ARG VERSION=7.8.0
ARG COMPONENT=filebeat
ARG INSTALLATION_PATH=/opt/$COMPONENT
ARG TMP_PATH=/tmp
ARG SOURCE=$COMPONENT-$VERSION-linux-x86_64
ARG FILE=$SOURCE.tar.gz

# Label
LABEL maintainer="alessandro.carrega@cnit.it"
LABEL description="$COMPONENT image based on Alpine Linux"
LABEL version=$VERSION

# Download
RUN wget https://artifacts.elastic.co/downloads/beats/$COMPONENT/$FILE $TMP_PATH/
RUN tar xzvf $TMP_PATH/$FILE
RUN mv $TMP_PATH/$SOURCE $INSTALLATION_PATH
RUN rm $TMP_PATH/*

# Variables
ENV MONITORING_ENABLED=false
ENV ELASTICSEARCH_HOSTS=localhost:9200
ENV LOGSTASH_HOSTS=localhost:5044

# Settings
COPY settings/$COMPONENT.yml $INSTALLATION_PATH/
COPY settings/config/* $INSTALLATION_PATH/config/

# Run
WORKDIR $INSTALLATION_PATH
ENTRYPOINT ["$INSTALLATION_PATH/$COMPONENT"]
