#!/bin/bash
# ASTRID - LCP
# author: Alex Carrega <alessandro.carrega@cnit.it>

set_var() {
    [ ! -v $1 ] && export $1="$2"
}

set_var COMPONENT lcp
set_var VERSION master
set_var PROJECT astrid
set_var INSTALLATION_PATH /opt/$COMPONENT

set_var TMP_PATH /tmp
set_var PIDFILE $TMP_PATH/$COMPONENT.pid

set_var LCP_HOST 0.0.0.0
set_var LCP_PORT 4000
set_var LCP_AUTH_MAX_TTL 10min
set_var LCP_POLYCUBE_HOST localhost
set_var LCP_POLYCUBE_PORT 9000
set_var LCP_POLYCUBE_TIMEOUT 20s
set_var LCP_DEV_USERNAME lcp
# Password: "astrid" hashed in sha256
set_var LCP_DEV_PASSWORD 9c804f2550e31d8f98ac9b460cfe7fbfc676c5e4452a261a2899a1ea168c0a50
set_var LCP_LOG_LEVEL DEBUG
