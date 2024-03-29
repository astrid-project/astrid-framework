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

RUN apk add --no-cache --virtual .build-deps gcc musl-dev linux-headers libffi-dev cargo openssl-dev

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

RUN apk add --no-cache curl curlie

COPY --from=git-clone $INSTALLATION_PATH $INSTALLATION_PATH
COPY --from=pip-requirements $INSTALLATION_PATH /usr/local

COPY settings/$VERSION/config.ini $INSTALLATION_PATH/

# Execute
WORKDIR $INSTALLATION_PATH
ENTRYPOINT [ "python3" ]
CMD [ "main.py" ]

# Port
EXPOSE $LCP_PORT
