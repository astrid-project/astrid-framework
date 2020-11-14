#!/bin/bash
# ASTRID
# author: Alex Carrega <alessandro.carrega@cnit.it>


if [ -z "$1" ]; then
    echo "Error: missing Elasticsearch endpoint"
    echo "Usage: $0 <elasticsearch-endpoint> [<grafana-port>]"
    exit 1
fi

if [ -z "$2" ]; then
    GRAFANA_PORT=3000
else
    GRAFANA_PORT=$2
fi

ELASTICSEARCH_ENDPOINT=$1

docker run -d -p $GRAFANA_PORT:3000 \
    -e DS_NAME="Elasticsearch" -e DS_TYPE="elasticsearch" \
    -e DS_URL="http://$ELASTICSEARCH_ENDPOINT" \
    -e GF_USER="admin" -e GF_PASS="astrid" \
    --name=grafana -v grafana-storage:/var/lib/grafana qapps/grafana-docker:master

