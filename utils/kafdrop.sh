#!/bin/bash
# ASTRID
# author: Alex Carrega <alessandro.carrega@cnit.it>

usage() {
    echo "Usage: $0 <kafdrop-port> <kafka-ip-address> <kafka-port>"
    exit $1
}

if [ -z "$1" ] ; then
    echo "Error: missing Kafdrop port"
    usage 1
fi

if [ -z "$2" ] ; then
    echo "Error: missing Kafka IP address"
    usage 2
fi

if [ -z "$3" ] ; then
    echo "Error: missing Kafka port"
    usage 3
fi

KAFDROP_PORT=$1
KAFKA_IP_ADDRESS=$2
KAFKA_IP_PORT=$3
NAME=kafdrop

docker stop $NAME
docker rm $NAME
docker run --restart=always -it --add-host kafka:$KAFKA_IP_ADDRESS -d -p $KAFDROP_PORT:9000 \
    -e KAFKA_BROKERCONNECT=$KAFKA_IP_ADDRESS:$KAFKA_IP_PORT -e JVM_OPTS="-Xms32M -Xmx64M" \
    -e SERVER_SERVLET_CONTEXTPATH="/" --name $NAME obsidiandynamics/kafdrop
