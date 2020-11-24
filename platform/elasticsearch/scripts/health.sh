#!bin/bash
# ASTRID - Elasticsearch
# author: Alex Carrega <alessandro.carrega@cnit.it>

# Check if elasticsearch is running or not

WORK_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$WORK_PATH/vars.sh"

if [ -f $PIDFILE ]; then
    echo "$COMPONENT started"
else
    echo "$COMPONENT not started"
fi
