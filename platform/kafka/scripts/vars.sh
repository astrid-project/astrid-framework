#!/bin/bash
# ASTRID - Kafka
# author: Alex Carrega <alessandro.carrega@cnit.it>

set_var() {
    [ ! -v $1 ] && export $1="$2"
}

set_var COMPONENT kafka
set_var COMPONENT_DEP zookeeper
set_var VERSION 2.6.2
set_var SCALA_VERSION 2.12
set_var PROJECT astrid

set_var SOURCE ${COMPONENT}_$SCALA_VERSION-$VERSION
set_var FILE $SOURCE.tgz

set_var INSTALLATION_PATH /opt/$COMPONENT
set_var COMPONENT_PATH /opt/component
set_var TMP_PATH /tmp

set_var PIDFILE $TMP_PATH/$COMPONENT.pid
set_var PIDFILE_DEP $TMP_PATH/$COMPONENT_DEP.pid

set_var ZOOKEEPER_PORT 2181
set_var KAFKA_PORT 9092
