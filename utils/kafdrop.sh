#!/bin/bash
# ASTRID
# author: Alex Carrega <alessandro.carrega@cnit.it>

KAFKA_ENDPOINT=localhost

docker run --restart=always -it --add-host kafka:KAFKA_ENDPOINT -d -p 9000:9000 \
    -e KAFKA_BROKERCONNECT=KAFKA_ENDPOINT:9092 -e JVM_OPTS="-Xms32M -Xmx64M" \
    -e SERVER_SERVLET_CONTEXTPATH="/" --name kafdrop obsidiandynamics/kafdrop
