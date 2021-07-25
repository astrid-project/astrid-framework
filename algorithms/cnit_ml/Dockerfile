ASTRID - CNIT Machine Learning
# author: Alex Carrega <alessandro.carrega@cnit.it>

# Stage GIT CLONE
FROM alpine/git as git-clone

ARG COMPONENT=cnit_ml
ARG BRANCH=main
ARG VERSION=version3
ARG PROJECT=astrid
ARG INSTALLATION_PATH=/opt/$COMPONENT

RUN git clone https://github.com/$PROJECT-project/$COMPONENT --branch $BRANCH $INSTALLATION_PATH


# Stage PIP REQUIREMENTS
FROM python:3.7-slim as pip-requirements

ARG COMPONENT=cnit_ml
ARG BRANCH=main
ARG VERSION=version3
ARG PROJECT=astrid
ARG INSTALLATION_PATH=/opt/$COMPONENT

COPY --from=git-clone $INSTALLATION_PATH/$VERSION/requirements.txt /requirements.txt
RUN pip install --prefix=$INSTALLATION_PATH -r /requirements.txt


# Stage FINAL
FROM python:3.7-slim as final

ARG COMPONENT=cnit_ml
ARG BRANCH=main
ARG VERSION=version3
ARG PROJECT=astrid
ARG INSTALLATION_PATH=/opt/$COMPONENT

ENV KAFKA_BOOTSTRAP_SERVERS=localhost:9092
ENV KAFKA_TOPIC=network-data

LABEL maintainer="alessandro.carrega@cnit.it"
LABEL description="CNIT Machine Learning"
LABEL version=$VERSION

COPY --from=git-clone $INSTALLATION_PATH/$VERSION $INSTALLATION_PATH
COPY --from=pip-requirements $INSTALLATION_PATH /usr/local

COPY settings/$VERSION/.env $INSTALLATION_PATH/

# Execute
WORKDIR $INSTALLATION_PATH
ENTRYPOINT [ "python" ]
CMD [ "deployment.py" ]
