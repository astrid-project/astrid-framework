#!/bin/bash
# ASTRID
# author: Alex Carrega <alessandro.carrega@cnit.it>

NAME=portainer

docker stop $NAME
docker rm $NAME
docker volume create portainer_data
docker run -d -p 8000:8000 -p 9000:9000 \
    --name=$NAME --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data \
    portainer/portainer-ce
