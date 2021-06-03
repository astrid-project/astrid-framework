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
set_var COMPONENT_PATH /opt/component
set_var TMP_PATH /tmp

set_var PIDFILE $TMP_PATH/$COMPONENT.pid

WORK_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$WORK_PATH/../settings/$VERSION/.env"
export $(cut -d= -f1 "$WORK_PATH/../settings/$VERSION/.env")
