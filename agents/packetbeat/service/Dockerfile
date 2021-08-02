# ASTRID - Packetbeat
# author: Alex Carrega <alessandro.carrega@cnit.it>


FROM astridproject/restable:master as restable

FROM ubuntu:latest as final

# Args
ARG COMPONENT=packetbeat
ARG VERSION=7.13.4
ARG INSTALLATION_PATH=/usr/share/$COMPONENT
ARG RESTable_PATH=/opt/RESTable

# Label
LABEL maintainer="alessandro.carrega@cnit.it"
LABEL description="$COMPONENT image (service) based on Ubuntu"
LABEL version=$VERSION

# Variables
ENV COMPONENT=$COMPONENT
ENV VERSION=$VERSION
ENV INSTALLATION_PATH=$INSTALLATION_PATH

# Component execution deps
RUN apt update
RUN apt install -y wget apt-transport-https gnupg

# Download
RUN wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
RUN echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-7.x.list
RUN apt-get update
RUN apt-get install -y packetbeat

# Settings
COPY --from=restable $RESTable_PATH $RESTable_PATH
COPY --from=restable -rf /usr/local/* /usr/local

COPY settings/$VERSION/$COMPONENT.yml $INSTALLATION_PATH/
COPY settings/$VERSION/RESTable-settings.yaml $RESTable_PATH/settings.yaml
RUN chmod +x $RESTable_PATH/prod.sh

# Execute
WORKDIR $RESTable_PATH
ENTRYPOINT [ "./prod.sh" ]
