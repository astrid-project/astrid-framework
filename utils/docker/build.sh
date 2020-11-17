#!/bin/bash
# ASTRID
# author: Alex Carrega <alessandro.carrega@cnit.it>

usage() {
    echo "Usage: $0 <dockerfile-path> <component-version>"
    exit $1
}

if [ -z "$1" ]; then
    echo "Error: missing Dockerfile path"
    usage 1
fi

if [ -z "$2" ]; then
    echo "Error: missing component version"
    usage 2
fi

DOCKERFILE_PATH=$1

if [ ! -d "$DOCKERFILE_PATH/settings/$2" ]; then
    echo "Error: unknown component version"
    usage 3
fi

source "$DOCKERFILE_PATH/scripts/vars"

VERSION=$2

if [ -z "$DOCKER_TAG" ]; then
    DOCKER_TAG="${PROJECT}project/$COMPONENT:$VERSION"
fi

echo "Build image -- $DOCKER_TAG"
docker build --rm=true --no-cache --build-arg VERSION=$VERSION -t $DOCKER_TAG "$DOCKERFILE_PATH"
