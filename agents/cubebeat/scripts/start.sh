#!/bin/bash
# ASTRID - Cubebeat
# author: Alex Carrega <alessandro.carrega@cnit.it>

# Start cubebeat

WORK_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$WORK_PATH/vars.sh"

if [ -f "$PIDFILE" ] ; then
    echo "Error: $COMPONENT already started"
    echo "Note: to force the start please remove $PIDFILE"
else
    cd "$INSTALLATION_PATH"
    "./$COMPONENT" > /tmp/$COMPONENT.log &
    echo "$!" > "$PIDFILE"
fi
