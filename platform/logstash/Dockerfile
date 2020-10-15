# ASTRID - Logstash
# author: Alex Carrega <alessandro.carrega@cnit.it>

# Image
ARG OS_VERSION=3.12.0
FROM alpine:$OS_VERSION

# Args
ARG COMPONENT=logstash
ARG VERSION=7.8.0
ARG INSTALLATION_PATH=/opt/$COMPONENT
ARG TMP_PATH=/tmp
ARG SOURCE=$COMPONENT-$VERSION
ARG FILE=$SOURCE.tar.gz

# Label
LABEL maintainer="alessandro.carrega@cnit.it"
LABEL description="$COMPONENT image based on Alpine Linux"
LABEL version=$VERSION

# Download
RUN wget -P $TMP_PATH/ https://artifacts.elastic.co/downloads/$COMPONENT/$FILE
RUN tar xzvf $TMP_PATH/$FILE -C $TMP_PATH/
RUN mv $TMP_PATH/$SOURCE $INSTALLATION_PATH
RUN rm $TMP_PATH/$FILE

# Variables
ENV ELASTICSEARCH_MONITORING_ENABLED=false
ENV ELASTICSEARCH_HOSTS=localhost:9200
ENV KAFKA_BOOTSTRAP_SERVERS=localhost:9092

# Settings
RUN mkdir -p $INSTALLATION_PATH/config
COPY settings/$VERSION/config/* $INSTALLATION_PATH/config/
RUN mkdir -p $INSTALLATION_PATH/pipeline
COPY settings/$VERSION/pipeline/* $INSTALLATION_PATH/pipeline/

# Execute
WORKDIR $INSTALLATION_PATH
ENTRYPOINT [ "./$COMPONENT" ]
