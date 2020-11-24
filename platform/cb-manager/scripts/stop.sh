#!/bin/bash
# ASTRID - CB Manager
# author: Alex Carrega <alessandro.carrega@cnit.it>

# Stop the cb-manager

WORK_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$WORK_PATH/vars.sh"

if [ -f $PIDFILE ]; then
    kill $(cat $PIDFILE)
    rm -f $PIDFILE
else
    echo "Error: $COMPONENT not started"
fi
