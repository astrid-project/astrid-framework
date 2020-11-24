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

# FIXME execution of commands not working
docker exec -it $COMPONENT.$VERSION apk add git bash
docker exec -it $COMPONENT.$VERSION sh -c "$(wget https://raw.githubusercontent.com/alexcarrega/oh-my-bash/master/tools/install.sh -O -)"
