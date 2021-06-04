#!/bin/bash
# ASTRID - Elasticsearch
# author: Alex Carrega <alessandro.carrega@cnit.it>

# Start elasticsearch

WORK_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$WORK_PATH/vars.sh"

if [ -f "$PIDFILE" ] ; then
    echo "Error: $COMPONENT already started"
    echo "Note: to force the start please remove $PIDFILE"
else
    cd "$INSTALLATION_PATH"
    "./bin/$COMPONENT" > /tmp/$COMPONENT.log &
    echo "$!" > "$PIDFILE"
fi
