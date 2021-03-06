#!bin/bash
# ASTRID - Packetbeat
# author: Alex Carrega <alessandro.carrega@cnit.it>

# Check if packetbeat is running or not

WORK_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$WORK_PATH/vars.sh"

if [ -f "$PIDFILE" ]; then
    echo "$COMPONENT started"
else
    echo "$COMPONENT not started"
fi
