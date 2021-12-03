# ASTRID - Kafka
# author: Alex Carrega <alessandro.carrega@cnit.it>

# Image
ARG OS_VERSION=3.12.0
FROM alpine:$OS_VERSION

# Args
ARG COMPONENT=kafka
ARG COMPONENT_DEP=zookeeper
ARG VERSION=2.6.3
ARG SCALA_VERSION=2.12
ARG INSTALLATION_PATH=/opt/$COMPONENT
ARG SOURCE=${COMPONENT}_$SCALA_VERSION-$VERSION
ARG FILE=$SOURCE.tgz
ARG TMP_PATH=/tmp

# Label
LABEL maintainer="alessandro.carrega@cnit.it"
LABEL description="$COMPONENT image based on Alpine Linux"
LABEL version=$VERSION

# Download
RUN wget -P $TMP_PATH/ https://downloads.apache.org/$COMPONENT/$VERSION/$FILE
RUN tar -xzf $TMP_PATH/$FILE -C $TMP_PATH/
RUN mv $TMP_PATH/$SOURCE $INSTALLATION_PATH
RUN rm $TMP_PATH/$FILE

# Component execution deps
RUN apk add libc6-compat

# Variables
ENV COMPONENT=$COMPONENT
ENV VERSION=$VERSION
ENV INSTALLATION_PATH=$INSTALLATION_PATH

ENV ZOOKEEPER_PORT=2181
ENV KAFKA_PORT=9092

# Settings
COPY settings/$VERSION/entrypoint.sh $INSTALLATION_PATH/
RUN chmod +x $INSTALLATION_PATH/entrypoint.sh
RUN mkdir -p $INSTALLATION_PATH/config
COPY settings/$VERSION/config/* $INSTALLATION_PATH/config/

# Execute
WORKDIR $INSTALLATION_PATH
ENTRYPOINT [ "/opt/kafka/entrypoint.sh" ]
