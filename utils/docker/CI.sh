#!/bin/bash
# GUARD
# author: Alex Carrega <alessandro.carrega@cnit.it>

WORK_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

DOCKERFILE_PATHS="../../core_framework/context_broker/cb-manager \
                  ../../local_sidercars/local_control_management/lcp \
                  ../../local_sidercars/monitoring/filebeat \
                  ../../local_sidercars/monitoring/metricbeat \
                  ../../local_sidercars/data_fusion/logstash/central
                  ../../local_sidercars/data_fusion/logstash/local"

for dockerfile_path in $DOCKERFILE_PATHS; do
    COMPONENT_NAME=$(basename "$dockerfile_path")
    if [ "$COMPONENT_NAME" == "local" ] || [ "$COMPONENT_NAME" == "central" ]; then
        COMPONENT_NAME="logstash-$COMPONENT_NAME"
    fi
    for version in $(ls "$WORK_DIR/$dockerfile_path/settings"); do
        echo "---------------------------------------------------------"
        echo "$COMPONENT_NAME   $version"
        echo -e "---------------------------------------------------------\n"
        bash "$WORK_DIR/build.sh" "$WORK_DIR/$dockerfile_path" $version
        bash "$WORK_DIR/push.sh" "$COMPONENT_NAME" $version
        echo -e "\n\n"
    done
done

echo "Clean Docker local instance"
docker images prune
