# ASTRID - CB Manager
# author: Alex Carrega <alessandro.carrega@cnit.it>

# Stage GIT CLONE
FROM alpine/git as git-clone

ARG COMPONENT=cb-manager
ARG VERSION=master
ARG PROJECT=astrid
ARG INSTALLATION_PATH=/opt/$COMPONENT

RUN git clone https://github.com/$PROJECT-project/$COMPONENT --branch $VERSION $INSTALLATION_PATH


# Stage PIP REQUIREMENTS
FROM python:3.8-alpine as pip-requirements

ARG COMPONENT=cb-manager
ARG VERSION=master
ARG PROJECT=astrid
ARG INSTALLATION_PATH=/opt/$COMPONENT

RUN apk add --no-cache --virtual .build-deps gcc musl-dev linux-headers

COPY --from=git-clone $INSTALLATION_PATH/requirements.txt /requirements.txt
RUN pip install --prefix=$INSTALLATION_PATH -r /requirements.txt


# Stage FINAL
FROM python:3.8-alpine as final

ARG COMPONENT=cb-manager
ARG VERSION=master
ARG PROJECT=astrid
ARG INSTALLATION_PATH=/opt/$COMPONENT

LABEL maintainer="alessandro.carrega@cnit.it"
LABEL description="CB-Manager built with Python version 3.8 on Alpine Linux"
LABEL version=$VERSION

ENV CB_MAN_HOST=0.0.0.0
ENV CB_MAN_PORT=5000
ENV CB_MAN_HEARTBEAT_TIMEOUT=1min
ENV CB_MAN_HEARTBEAT_PERIOD=20s
ENV CB_MAN_HEARTBEAT_AUTH_EXPIRATION=5min
ENV CB_MAN_ELASTICSEARCH_ENDPOINT=localhost:9200
ENV CB_MAN_ELASTICSEARCH_TIMEOUT=20s
ENV CB_MAN_ELASTICSEARCH_RETRY_PERIOD=1min
ENV CB_MAN_DEV_USERNAME=cb-manager
## Password: "astrid" hashed in sha256
ENV CB_MAN_DEV_PASSWORD=9c804f2550e31d8f98ac9b460cfe7fbfc676c5e4452a261a2899a1ea168c0a50
ENV CB_MAN_LOG_LEVEL=DEBUG

COPY --from=git-clone $INSTALLATION_PATH $INSTALLATION_PATH
COPY --from=pip-requirements $INSTALLATION_PATH /usr/local

COPY settings/$VERSION/config.ini $INSTALLATION_PATH/

# Execute
WORKDIR $INSTALLATION_PATH
ENTRYPOINT [ "python3" ]
CMD [ "main.py" ]

# Port
EXPOSE $CB_MAN_PORT
