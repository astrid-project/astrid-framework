# ASTRID - Elasticsearch
# author: Alex Carrega <alessandro.carrega@cnit.it>

# Image
ARG OS_VERSION=3.12.0
FROM alpine:$OS_VERSION

# Args
ARG COMPONENT=elasticsearch
ARG VERSION=7.8.0
ARG INSTALLATION_PATH=/opt/$COMPONENT
ARG TMP_PATH=/tmp
ARG SOURCE=$COMPONENT-$VERSION
ARG FILE=$SOURCE-linux-x86_64.tar.gz

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
ENV ELASTICSEARCH_PORT=9200
ENV ELASTICSEARCH_MONITORING_ENABLED=false
ENV ELASTICSEARCH_TRANSPORT_TCP_PORT=9300

# Settings
RUN mkdir -p config
COPY settings/$VERSION/config/* config/

# Execute
WORKDIR $INSTALLATION_PATH
ENTRYPOINT [ "$INSTALLATION_PATH/$COMPONENT" ]
