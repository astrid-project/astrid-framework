#!/bin/bash
# ASTRID - Kafka
# author: Alex Carrega <alessandro.carrega@cnit.it>

# Start kafka

WORK_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$WORK_PATH/vars.sh"

if [ -f "$PIDFILE" ] ; then
    echo "Error: $COMPONENT already started"
    echo "Note: to force the start please remove $PIDFILE"
else
    cd "$INSTALLATION_PATH"
    "./bin/$COMPONENT_DEP-server-start.sh" "./config/$COMPONENT_DEP.properties" > /tmp/$COMPONENT_DEP.log &
    echo "$!" > "$PIDFILE_DEP"
    "./bin/$COMPONENT-server-start.sh" "./config/$COMPONENT.properties" > /tmp/$COMPONENT.log &
    echo "$!" > "$PIDFILE"
fi
