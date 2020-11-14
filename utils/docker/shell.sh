#!/bin/bash
# ASTRID
# author: Alex Carrega <alessandro.carrega@cnit.it>

usage() {
    echo "Usage: $0 <component-name> <component-version>"
    exit $1
}

if [ -z "$1" ]; then
    echo "Error: missing component name"
    usage 1
fi

if [ -z "$2" ]; then
    echo "Error: missing component version"
    usage 2
fi

COMPONENT=$1
VERSION=$2

docker exec -it $COMPONENT.$VERSION [ -f /bin/bash ] && /bin/bash || /bin/sh
