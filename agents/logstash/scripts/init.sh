#!bin/bash
# ASTRID - Logstash
# author: Alex Carrega <alessandro.carrega@cnit.it>

# Download the binary and copy the configuration files

WORK_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$WORK_PATH/vars.sh"

if [ -d "$INSTALLATION_PATH" ]; then
    echo "Error: component $COMPONENT already initialized in $INSTALLATION_PATH"
    exit 1
fi

if [ ! -f $TMP_PATH/$FILE ]; then
    wget -P $TMP_PATH/ https://artifacts.elastic.co/downloads/$COMPONENT/$FILE
fi
unzip $TMP_PATH/$FILE -d $TMP_PATH/
mv $TMP_PATH/$SOURCE $INSTALLATION_PATH

mkdir -p $INSTALLATION_PATH/config
cp $WORK_PATH/../settings/$VERSION/config/* $INSTALLATION_PATH/config/

mkdir -p $INSTALLATION_PATH/pipeline
cp $WORK_PATH/../settings/$VERSION/pipeline/* $INSTALLATION_PATH/pipeline/
