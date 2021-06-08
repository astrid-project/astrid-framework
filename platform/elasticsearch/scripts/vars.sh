#!/bin/bash
# ASTRID - Elasticsearch
# author: Alex Carrega <alessandro.carrega@cnit.it>

set_var() {
    [ ! -v $1 ] && export $1="$2"
}

set_var COMPONENT elasticsearch
set_var VERSION 7.8.0
set_var PROJECT astrid

set_var SOURCE $COMPONENT-$VERSION
set_var FILE $SOURCE-linux-x86_64.tar.gz

set_var INSTALLATION_PATH /opt/astrid/$COMPONENT
set_var COMMANDS_PATH /opt/astrid/commands
set_var TMP_PATH /tmp

set_var PIDFILE $TMP_PATH/$COMPONENT.pid

set_var ELASTICSEARCH_PORT 9200
set_var ELASTICSEARCH_MONITORING_ENABLED false
set_var ELASTICSEARCH_TRANSPORT_TCP_PORT 9300
