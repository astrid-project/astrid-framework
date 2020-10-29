#!/bin/bash
# ASTRID - CB Manager
# author: Alex Carrega <alessandro.carrega@cnit.it>

# Check if the cb-manager is running or not

CB_PATH="/opt/cb-manager/"
KAFKA_PATH="/opt/kafka/"

if [ -z "$1" ]; then
    echo "Error: missing service [kafka|zookeeper|cb-manager]"
elif [ "$1" == "kakfa" ]; then
    if [ -z "$2" ]; then
        echo "Error: missing action [start|stop]"
    elif [ "$2" == "start" ]; then
        screen -S kafka -dm $KAFKA_PATH/bin/kafka-server-start.sh $KAFKA_PATH/config/server.properties
    elif [ "$2" == "stop" ]; then
        screen -S kafka -X quit
    else
        echo "Error: unknown action, must be: start|stop"
    fi
elif [ "$1" == "zookeeper" ]; then
    if [ -z "$2" ]; then
        echo "Error: missing action [start|stop]"
    elif [ "$2" == "start" ]; then
        screen -S zookeeper -dm $KAFKA_PATH/bin/zookeeper-server-start.sh $KAFKA_PATH/config/zookeeper.properties
    elif [ "$2" == "stop" ]; then
        screen -S zookeeper -X quit
    else
        echo "Error: unknown action, must be: start|stop"
    fi
elif [ "$1" == "cb-manager" ]; then
    if [ -z "$2" ]; then
        echo "Error: missing action [start|stop]"
    elif [ "$2" == "start" ]; then
        screen -S contextbroker -dm /usr/bin/python3 $CB_PATH/main.py
    elif [ "$2" == "stop" ]; then
        screen -S contextbroker -X quit
    else
        echo "Error: unknown action, must be: start|stop"
    fi
else
    echo "Error: unknown service, must be: kafka|zookeeper|cb-manager"
fi
