#!bin/bash
# ASTRID - k8s configuration
# author: Alex Carrega <alessandro.carrega@cnit.it>

if [ -z $1 ]; then
    echo "Error: missing mode"
elif [ ! -f "backend/context-broker-$1.yaml" ]; then
    echo "Error: unknown mode"
else
    MODE=$1

    ## Create the astrid-kube namespace
    kubectl apply -f common/namespace.yaml

    ## Config-maps for elasticsearch and logstash setting files
    kubectl -n astrid-kube create configmap elasticsearch-config --from-file=../platform/elasticsearch/settings/7.8.0/config/ -o yaml
    kubectl -n astrid-kube create configmap logstash-config --from-file=../platform/logstash/settings/7.8.0/config/ -o yaml
    kubectl -n astrid-kube create configmap logstash-pipeline --from-file=../platform/logstash/settings/7.8.0/pipeline/ -o yaml

    ## Persistence storage for elasticsearch
    kubectl apply -f common/storage.yaml

    ## Service for cb-manager, elasticsearch and kafka
    kubectl apply -f backend/service.yaml

    ## Set the context broker
    kubectl apply -f backend/context-broker-$MODE.yaml
fi
