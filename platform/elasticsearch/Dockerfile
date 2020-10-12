# ASTRID - CB Manager
# author: Alex Carrega <alessandro.carrega@cnit.it>

# Image
ARG OS_VERSION=3.12.0
FROM alpine:$OS_VERSION

# Args
ARG VERSION=7.8.0
ARG COMPONENT=elasticsearch
ARG INSTALLATION_PATH=/opt/$COMPONENT
ARG TMP_PATH=/tmp
ARG SOURCE=$COMPONENT-$VERSION-linux-x86_64
ARG FILE=$SOURCE.tar.gz

# Label
LABEL maintainer="alessandro.carrega@cnit.it"
LABEL description="$COMPONENT image based on Alpine Linux"
LABEL version=$VERSION

# Download
RUN cd $TMP_PATH \
    && wget https://artifacts.elastic.co/downloads/$COMPONENT/$FILE \
    && tar xzvf $TMP_PATH/$FILE \
    && mv $TMP_PATH/$SOURCE $INSTALLATION_PATH \
    && rm $TMP_PATH/*

# Settings
WORKDIR $INSTALLATION_PATH
RUN mkdir -p config
COPY settings/config/* config/

# Run
ENTRYPOINT ["$INSTALLATION_PATH/$COMPONENT"]
