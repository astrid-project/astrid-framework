#!bin/bash
# ASTRID - Elasticsearch
# author: Alex Carrega <alessandro.carrega@cnit.it>

# Download the binary and copy the configuration files

WORK_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$WORK_PATH/vars.sh"

mkdir -p $COMPONENT_PATH
ln -fs $WORK_PATH $COMPONENT_PATH/$COMPONENT

if [ "$1" == "-nc" ] || [ "$1" == "--no-cache" ]; then
    rm -rf "$TMP_PATH/$FILE"
fi

if [ ! -f "$TMP_PATH/$FILE" ]; then
    wget -P "$TMP_PATH/" "https://artifacts.elastic.co/downloads/$COMPONENT/$FILE"
else
    echo "Info: get $COMPONENT from cache"
fi
tar xzvf "$TMP_PATH/$FILE" -C "$TMP_PATH/"

rm -rf "$INSTALLATION_PATH"
mv "$TMP_PATH/$SOURCE" "$INSTALLATION_PATH"

mkdir -p "$INSTALLATION_PATH/config"
cp $WORK_PATH/../settings/$VERSION/config/* "$INSTALLATION_PATH/config/"
