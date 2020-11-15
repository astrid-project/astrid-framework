#!/bin/bash
# ASTRID
# author: Alex Carrega <alessandro.carrega@cnit.it>

if [ -z "$1" ]; then
    echo "Error: missing Kafka IP address"
    echo "Usage: $0 <kafka-ip-address>"
    exit 1
fi

KAFDROP_PORT=9001
KAFKA_IP_ADDRESS=$1

docker run --restart=always -it --add-host kafka:$KAFKA_IP_ADDRESS -d -p $KAFDROP_PORT:9000 \
    -e KAFKA_BROKERCONNECT=$KAFKA_IP_ADDRESS:9092 -e JVM_OPTS="-Xms32M -Xmx64M" \
    -e SERVER_SERVLET_CONTEXTPATH="/" --name kafdrop obsidiandynamics/kafdrop
