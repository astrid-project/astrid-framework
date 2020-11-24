#!/bin/bash
# ASTRID - Kafka
# author: Alex Carrega <alessandro.carrega@cnit.it>

# Stop kafka

WORK_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$WORK_PATH/vars.sh"

if [ -f $PIDFILE ]; then
    kill $(cat $PIDFILE)
    rm -f $PIDFILE
else
    echo "Error: $COMPONENT not started"
fi

if [ -f $PIDFILE_DEP ]; then
    kill $(cat $PIDFILE_DEP)
    rm -f $PIDFILE_DEP
else
    echo "Error: $COMPONENT_DEP not started"
fi
