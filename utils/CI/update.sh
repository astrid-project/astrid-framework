#!bin/bash
# ASTRID
# author: Alex Carrega <alessandro.carrega@cnit.it>

WORK_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CB_PATH="/opt/cb-manager/"

if [ "$1" == "cb-manager" ]; then
    echo "$1 - Update repo"
    cd $INSTALLATION_PATH
    git checkout '*'
    git pull

    echo "$1 - Restart"
    bash "$WORK_DIR/service.sh" "$1" stop
    bash "$WORK_DIR/service.sh" "$1" start
else
    echo "Error: unknown service, must be: cb-manager"
fi
