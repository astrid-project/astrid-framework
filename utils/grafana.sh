#!/bin/bash
# ASTRID
# author: Alex Carrega <alessandro.carrega@cnit.it>

if [ -z "$1" ]; then
    GRAFANA_PORT=3000
else
    GRAFANA_PORT=$1
fi

NAME=grafana

docker stop $NAME
docker rm $NAME
docker run -d -p $GRAFANA_PORT:3000 \
    --name=$NAME -v grafana-storage:/var/lib/grafana grafana/grafana
