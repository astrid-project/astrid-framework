#!bin/bash
# ASTRID - Kafka
# author: Alex Carrega <alessandro.carrega@cnit.it>

# Download the binary and copy the configuration files

WORK_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$WORK_PATH/vars.sh"

if [ -d "$INSTALLATION_PATH" ]; then
    echo "Error: component $COMPONENT already initialized in $INSTALLATION_PATH"
    exit 1
fi

if [ ! -f $TMP_PATH/$FILE ]; then
    wget -P $TMP_PATH/ https://downloads.apache.org/$COMPONENT/$VERSION/$FILE
fi
tar -xzf $TMP_PATH/$FILE -C $TMP_PATH/
mv $TMP_PATH/$SOURCE $INSTALLATION_PATH

mkdir -p $INSTALLATION_PATH/config
cp $WORK_PATH/../settings/$VERSION/config/* $INSTALLATION_PATH/config/
