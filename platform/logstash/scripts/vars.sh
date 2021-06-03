#!/bin/bash
# ASTRID - Logstash
# author: Alex Carrega <alessandro.carrega@cnit.it>

set_var() {
    [ ! -v $1 ] && export $1="$2"
}

set_var COMPONENT logstash
set_var VERSION 7.8.0
set_var PROJECT astrid

set_var SOURCE $COMPONENT-$VERSION
set_var FILE $SOURCE.zip

set_var INSTALLATION_PATH /opt/$COMPONENT
set_var COMPONENT_PATH /opt/component
set_var TMP_PATH /tmp

set_var PIDFILE $TMP_PATH/$COMPONENT.pid

set_var ELASTICSEARCH_HOSTS localhost:9200
set_var ELASTICSEARCH_MONITORING_ENABLED false
set_var KAFKA_BOOTSTRAP_SERVERS localhost:9092
