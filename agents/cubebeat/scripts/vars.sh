#!/bin/bash
# ASTRID - Cubebeat
# author: Alex Carrega <alessandro.carrega@cnit.it>

set_var() {
    [ ! -v $1 ] && export $1="$2"
}

set_var COMPONENT cubebeat
set_var VERSION master
set_var PROJECT astrid
set_var INSTALLATION_PATH "/opt/$COMPONENT"

set_var TMP_PATH /tmp
set_var PIDFILE "$TMP_PATH/$COMPONENT.pid"

set_var GOPATH /opt/go

set_var ELASTICSEARCH_HOSTS localhost:9200
set_var ELASTICSEARCH_MONITORING_ENABLED false
set_var LOGSTASH_HOSTS localhost:5044
