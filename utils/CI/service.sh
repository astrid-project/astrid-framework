#!/bin/bash
# ASTRID
# author: Alex Carrega <alessandro.carrega@cnit.it>

WORK_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CB_PATH="/opt/cb-manager/"
KAFKA_PATH="/opt/kafka/"

if [ -z "$1" ]; then
    echo "Error: missing service [kafka|zookeeper|cb-manager]"
    exit 1
elif [ "$1" == "kafka" ]; then
    if [ -z "$2" ]; then
        echo "Error: missing action [start|stop]"
        exit 2
    elif [ "$2" == "start" ]; then
        if ! screen -list | grep -q "kafka"; then
            screen -S kafka -dm $KAFKA_PATH/bin/kafka-server-start.sh $KAFKA_PATH/config/server.properties
        else
            echo "Error: kafka already running, use stop to close this session."
            exit 3
        fi
    elif [ "$2" == "stop" ]; then
        screen -S kafka -X quit
    else
        echo "Error: unknown action, must be: start|stop"
        exit 4
    fi
elif [ "$1" == "zookeeper" ]; then
    if [ -z "$2" ]; then
        echo "Error: missing action [start|stop]"
        exit 2
    elif [ "$2" == "start" ]; then
        if ! screen -list | grep -q "zookeeper"; then
            screen -S zookeeper -dm $KAFKA_PATH/bin/zookeeper-server-start.sh $KAFKA_PATH/config/zookeeper.properties
        else
            echo "Error: zookeeper already running, use stop to close this session."
            exit 3
        fi
    elif [ "$2" == "stop" ]; then
        screen -S zookeeper -X quit
    else
        echo "Error: unknown action, must be: start|stop"
        exit 4
    fi
elif [ "$1" == "cb-manager" ]; then
    if [ -z "$2" ]; then
        echo "Error: missing action [start|stop]"
        exit 2
    elif [ "$2" == "start" ]; then
        if ! screen -list | grep -q "contextbroker"; then
            screen -S contextbroker -dm /usr/bin/python3 $CB_PATH/main.py --es-endpoint localhost:9200
        else
            echo "Error: cb-manager already running, use stop to close this session."
            exit 3
        fi
    elif [ "$2" == "stop" ]; then
        screen -S contextbroker -X quit
    else
        echo "Error: unknown action, must be: start|stop"
        exit 4
    fi
else
    echo "Error: unknown service, must be: kafka|zookeeper|cb-manager"
    exit 5
fi

echo "Send notification via Telegram"
screen -ls | convert label:@- "$HOME/log/screen-ls.png"
bash "$WORK_DIR/utils/send2telegram/photo.sh" "$HOME/log/screen-ls.png" "{cnit-openstack} [$1] ($2)"
