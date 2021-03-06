#!bin/bash
# ASTRID - Kafka
# author: Alex Carrega <alessandro.carrega@cnit.it>

# Check if kafka is running or not

WORK_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$WORK_PATH/vars.sh"

if [ -f "$PIDFILE_DEP" ]; then
    echo "$COMPONENT_DEP started"
else
    echo "$COMPONENT_DEP not started"
fi

if [ -f "$PIDFILE" ]; then
    echo "$COMPONENT started"
else
    echo "$COMPONENT not started"
fi
