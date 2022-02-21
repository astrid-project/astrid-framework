# ASTRID - RESTable
# author: Alex Carrega <alessandro.carrega@cnit.it>

# Stage GIT CLONE
FROM alpine/git as git-clone

ARG COMPONENT=RESTable
ARG VERSION=master
ARG PROJECT=astrid
ARG INSTALLATION_PATH=/opt/$COMPONENT

RUN git clone https://github.com/astrid-project/$COMPONENT --branch $VERSION $INSTALLATION_PATH


# Stage PIP REQUIREMENTS
FROM python:3.8-alpine as pip-requirements

ARG COMPONENT=RESTable
ARG VERSION=master
ARG PROJECT=astrid
ARG INSTALLATION_PATH=/opt/$COMPONENT

COPY --from=git-clone $INSTALLATION_PATH/requirements.txt /requirements.txt
RUN pip install --prefix=$INSTALLATION_PATH -r /requirements.txt


# Stage FINAL
FROM python:3.8-alpine as final

ARG COMPONENT=RESTable
ARG VERSION=master
ARG PROJECT=astrid
ARG INSTALLATION_PATH=/opt/$COMPONENT

LABEL maintainer="alessandro.carrega@cnit.it"
LABEL description="RESTable built with Python version 3.8 on Alpine Linux"
LABEL version=$VERSION

COPY --from=git-clone $INSTALLATION_PATH $INSTALLATION_PATH
COPY --from=pip-requirements $INSTALLATION_PATH /usr/local
RUN chmod +x $INSTALLATION_PATH/run.sh

# Execute
WORKDIR $INSTALLATION_PATH
ENTRYPOINT [ "./run.sh" ]
