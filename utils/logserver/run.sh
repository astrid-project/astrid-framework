#!/bin/bash
# ASTRID
# author: Alex Carrega <alessandro.carrega@cnit.it>

WORK_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

usage() {
    echo "Usage: $0 <logserver-port>"
    exit $1
}

if [ -z "$1" ] ; then
    echo "Error: missing Logserver port"
    usage 1
fi

LOGSERVER_PORT=$1

NAME=logserver

docker stop $NAME
docker rm $NAME
docker run -d --restart always -p $LOGSERVER_PORT:$LOGSERVER_PORT \
    --name $NAME --net="host" \
    -v "$WORK_PATH/config.json:/logserver.json" \
    stratoscale/logserver -addr :$LOGSERVER_PORT
