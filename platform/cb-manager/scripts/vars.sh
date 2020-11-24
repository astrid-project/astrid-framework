#!/bin/bash
# ASTRID - CB Manager
# author: Alex Carrega <alessandro.carrega@cnit.it>

set_var() {
    [ ! -v $1 ] && export $1="$2"
}

set_var COMPONENT cb-manager
set_var VERSION master
set_var PROJECT astrid
set_var INSTALLATION_PATH /opt/$COMPONENT

set_var TMP_PATH /tmp
set_var PIDFILE $TMP_PATH/$COMPONENT.pid

set_var CB_MAN_HOST 0.0.0.0
set_var CB_MAN_PORT 5000
set_var CB_MAN_HEARTBEAT_TIMEOUT 10s
set_var CB_MAN_HEARTBEAT_PERIOD 1min
set_var CB_MAN_HEARTBEAT_AUTH_EXPIRATION 5min
set_var CB_MAN_ELASTICSEARCH_ENDPOINT localhost:9200
set_var CB_MAN_ELASTICSEARCH_TIMEOUT 20s
set_var CB_MAN_ELASTICSEARCH_RETRY_PERIOD 1min
set_var CB_MAN_DEV_USERNAME cb-manager
# Password: "astrid" hashed in sha256
set_var CB_MAN_DEV_PASSWORD 9c804f2550e31d8f98ac9b460cfe7fbfc676c5e4452a261a2899a1ea168c0a50
set_var CB_MAN_LOG_LEVEL DEBUG
