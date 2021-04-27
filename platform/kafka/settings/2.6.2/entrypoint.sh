# ASTRID - Kafka entrypoint for Docker image
# author: Alex Carrega <alessandro.carrega@cnit.it>

./bin/$COMPONENT_DEP-server-start.sh ./config/$COMPONENT_DEP.properties &
./bin/$COMPONENT-server-start ./config/$COMPONENT.properties &
