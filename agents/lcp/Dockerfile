# ASTRID - LCP
# author: Alex Carrega <alessandro.carrega@cnit.it>

# Stage GIT CLONE
FROM alpine/git as git-clone

ARG COMPONENT=lcp
ARG VERSION=master
ARG PROJECT=astrid
ARG INSTALLATION_PATH=/opt/$COMPONENT

RUN git clone https://github.com/$PROJECT-project/$COMPONENT --branch $VERSION $INSTALLATION_PATH


# Stage PIP REQUIREMENTS
FROM python:3.8-alpine as pip-requirements

ARG COMPONENT=lcp
ARG VERSION=master
ARG PROJECT=astrid
ARG INSTALLATION_PATH=/opt/$COMPONENT

RUN apk add --no-cache --virtual .build-deps gcc musl-dev linux-headers

COPY --from=git-clone $INSTALLATION_PATH/requirements.txt /requirements.txt
RUN pip install --prefix=$INSTALLATION_PATH -r /requirements.txt


# Stage FINAL
FROM python:3.8-alpine as final

ARG COMPONENT=lcp
ARG VERSION=master
ARG PROJECT=astrid
ARG INSTALLATION_PATH=/opt/$COMPONENT

LABEL maintainer="alessandro.carrega@cnit.it"
LABEL description="LCP built with Python version 3.8 on Alpine Linux"
LABEL version=$VERSION

ENV LCP_HOST=0.0.0.0
ENV LCP_PORT=4000
ENV LCP_AUTH_MAX_TTL=10min
ENV LCP_POLYCUBE_HOST=localhost
ENV LCP_POLYCUBE_PORT=9000
ENV LCP_POLYCUBE_TIMEOUT=20s
ENV LCP_DEV_USERNAME=lcp
## Password: "astrid" hashed in sha256
ENV LCP_DEV_PASSWORD=9c804f2550e31d8f98ac9b460cfe7fbfc676c5e4452a261a2899a1ea168c0a50
ENV LCP_LOG_LEVEL=DEBUG

COPY --from=git-clone $INSTALLATION_PATH $INSTALLATION_PATH
COPY --from=pip-requirements $INSTALLATION_PATH /usr/local

COPY settings/$VERSION/config.ini $INSTALLATION_PATH/

# Execute
WORKDIR $INSTALLATION_PATH
ENTRYPOINT [ "python3" ]
CMD [ "main.py" ]

# Port
EXPOSE $LCP_PORT
