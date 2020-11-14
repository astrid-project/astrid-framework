#!/bin/bash
# ASTRID
# author: Alex Carrega <alessandro.carrega@cnit.it>

usage() {
    echo "Usage: $0 <component-name> <component-version>"
    exit $1
}

if [ -z "$1" ]; then
    echo "Error: missing component name"
    usage 1
fi

if [ -z "$2" ]; then
    echo "Error: missing component version"
    usage 2
fi

PROJECT=astrid
COMPONENT=$1
VERSION=$2

if [ -z "$DOCKER_TAG" ]; then
    DOCKER_TAG="${PROJECT}project/$COMPONENT:$VERSION"
fi

echo "Push image -- $DOCKER_TAG"
docker login -u alexcarrega -p "6028e7fb-ecd4-43e8-ae0e-295727cf850c"
docker push $DOCKER_TAG
