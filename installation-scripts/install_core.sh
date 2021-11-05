#!/bin/bash

# Parameters
ASTRID_FRAMEWORK_GITHUB=https://github.com/astrid-project/astrid-framework.git
CB_POD_NAME="context-broker"
CB_POD_INSTANCE_NAME=""
CB_STATUS=""
# 60 is 5 minute (one loop for every 5 seconds)
POD_CHECK_TIMEOUT=60
CB_NAMESPACE="astrid-kube"
FILEBEAT_LOG_DATA_PATH="/var/log/*"
EXECENV_YML_TMP_FOLDER="./execs/tmp"
CB_AUTH_KEY='Authorization: ASTRID eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOiIxNjE2NzgxMDU4IiwiZXhwIjoiMTY0ODMxNzA1OCIsIm5iZiI6MTYxNjc4MTA1OH0.3eNv1XH_YDq_u5KFn8B79KMzXPXI1cypgjry9xKXlN4'
METRICBEAT="no"
FILEBEAT="no"
PACKETBEAT="no"
POLYCUBE="no"
PROBE="no"
BASE_PATH=$(pwd)

# Import external function
source ./execs/astrid-controller.sh
source ./execs/exec-env.sh
source ./execs/agent-catalog.sh
source ./execs/ebpf-program-catalog.sh
source ./execs/network-link.sh
#

function help()
{
  echo ""
  echo " * Script for Astrid Framework installation *"
  echo "    list of parameters:"
  echo "     -h | --help : show this help"
  echo "     -af | --astridframework: install Context Broker and Astrid Controller"
  echo "     -cb | --contextbroker: install Context Broker only"
  echo "     -ac | --astridcontroller: install Astrid Controller only"
  echo "     -ee X {-Y} | --executionenvironment X {-Y} "
  echo "         install X instances of Execution Environment"
  echo "         Y agent to activate (can be more that one):"
  echo "              -m  | --metricbeat"
  echo "              -f  | --filebeat"
  echo "              -p  | --packetbeat"
  echo "              -pc | --polycube"
  echo "              -pr | --probe"
  echo ""
  exit 0
}

# $1 is the name of the POD
function checkPod()
{
  local i=0
  while [ true ]
  do
    POD_STATUS=$(kubectl get pods --all-namespaces | grep $1 | awk '{ print $4}')
    if [ "${POD_STATUS}" != "Running" ]
    then
      echo -n "."
      sleep 5
      ((i++))
    else
      echo ""
      echo " * ${1} pod is running. Go ahead..."
      break
    fi
  
    if [ $i -gt $POD_CHECK_TIMEOUT ]
    then
      echo ""
      echo " ** ERROR: timeout: ${1} pod is not running"
      exit 1
    fi
  done
}

# $1 manifest path and name
# $2 keyword to find
function container_disable()
{
  sed -i ":a;N;\$!ba;s/#<${2}.*#${2}>//" $1
}

if [ $# -eq 0 ]
then
  help
else
  POSITIONAL=()
  while [[ $# -gt 0 ]]; do
    KEY="$1"

    case $KEY in
      -af|--astridframework)
        INSTALL_CB=YES
        INSTALL_AC=YES
        shift
        ;;
      -cb|--contextbroker)
        INSTALL_CB=YES
        shift
        ;;
      -ac|--astridcontroler)
        INSTALL_AC=YES
        shift
        ;;
      -h|--help)
        shift
        help
        ;;
      -ee|--executionenvironment)
        EXEC_ENV_INSTANCES=${2}
        case $EXEC_ENV_INSTANCES in
          ''|*[!0-9])
            echo "ERROR: bad parameter for \"-ee\" or \"--executionenvironment\" : "$EXEC_ENV_INSTANCES
            exit 1
            ;;
          *)
            ;;
        esac
        shift
        shift
        ;;
      -m|--metricbeat)
        METRICBEAT="yes"
        shift
        ;;
      -f|--filebeat)
        FILEBEAT="yes"
        shift
        ;;
      -p|--packetbeat)
        PACKETBEAT="yes"
        shift
        ;;
      -pc|--polycube)
        POLYCUBE="yes"
        shift
        ;;
      -pr|--probe)
        PROBE="yes"
        shift
        ;;
      *)
        POSITIONAL+=("$1")
        echo " unknown parameter: ${1}"
        shift
        ;;
    esac
  done
  set -- "${POSITIONAL[@]}"
fi

if [ "$INSTALL_CB" = YES ]
then
  echo " * Set max_map_count ..."
  sysctl -w vm.max_map_count=262144
  
  
  echo " * Download \"Astrid Framework\" code from ${ASTRID_FRAMEWORK_GITHUB} ..."
  git clone ${ASTRID_FRAMEWORK_GITHUB}
  
  echo " * Moving in \"Astrid Framework\" folder ..."
  cd astrid-framework/k8s
  
  echo " * Preparing for the \"Astrid Framework\" core installation ..."
  source run.sh dev > /dev/null
  
  echo " * Waiting for 5 seconds ..."
  for i in {1..5}
  do
    echo -n "."
    sleep 1
  done
  echo ""
  
  echo " * Check ContextBroker status ... "
  checkPod $CB_POD_NAME
  
  echo " * Retrieve ContextBroker Pod name ..."
  CB_POD_INSTANCE_NAME=$(kubectl get pods --all-namespaces | grep $CB_POD_NAME | awk '{ print $2 }')
  echo " * Context Broker instance name: "$CB_POD_INSTANCE_NAME
  
  echo " * Setting the storage (1/2) ..."
  kubectl exec -it --namespace=${CB_NAMESPACE} ${CB_POD_INSTANCE_NAME} -c elasticsearch -- /bin/bash -c "/bin/mkdir -p /node/mnt/elasticsearch-data"
  
  echo " * Setting the storage (2/2) ..."
  kubectl exec -it --namespace=${CB_NAMESPACE} ${CB_POD_INSTANCE_NAME} -c elasticsearch -- /bin/bash -c "/bin/chmod -R 777 /node/mnt/elasticsearch-data"

  echo " * Setting agent-catalog ..."
  kubectl exec -it --namespace=${CB_NAMESPACE} ${CB_POD_INSTANCE_NAME} -c elasticsearch -- bash -c "curl -XPOST -H 'Content-Type: application/json' -H \"${CB_AUTH_KEY}\" cb-manager-service:5000/catalog/agent -d $(agent_catalog)" > /dev/null 

  echo " * Setting program-catalog ..."
  kubectl exec -it --namespace=${CB_NAMESPACE} ${CB_POD_INSTANCE_NAME} -c elasticsearch -- bash -c "curl -XPOST -H 'Content-Type: application/json' -H \"${CB_AUTH_KEY}\" cb-manager-service:5000/catalog/ebpf-program -d $(ebpf_program_catalog)" > /dev/null 

  echo " * Setting exec-env-type ..."
  kubectl exec -it --namespace=${CB_NAMESPACE} ${CB_POD_INSTANCE_NAME} -c elasticsearch -- bash -c "curl -XPOST -H 'Content-Type: application/json' -H \"${CB_AUTH_KEY}\" cb-manager-service:5000/type/exec-env -d $(exec_env_types)" > /dev/null 

  echo " * Setting network-link-type ..."
  kubectl exec -it --namespace=${CB_NAMESPACE} ${CB_POD_INSTANCE_NAME} -c elasticsearch -- bash -c "curl -XPOST -H 'Content-Type: application/json' -H \"${CB_AUTH_KEY}\" cb-manager-service:5000/type/network-link -d $(network_link_types)" > /dev/null 
  
  echo " * Astrid Framework core installation completed"
fi

if [ "$INSTALL_AC" = YES ]
then
  astrid-controller-docker-image
  astrid-controller-k8s-deployment
fi

if [ ! -z $EXEC_ENV_INSTANCES ]
then
  echo " * Installation of Execution Environment(s) "
  echo " * Number of instances: "$EXEC_ENV_INSTANCES

  EE_NAMES=()
  # for every execenv run following code
  for (( i=1; i<=${EXEC_ENV_INSTANCES}; i++ ))
  do
    if [ -d "${EXECENV_YML_TMP_FOLDER}" ] 
    then
      rm -r ${EXECENV_YML_TMP_FOLDER}
    fi
    mkdir -p ${EXECENV_YML_TMP_FOLDER}

    cp ./execs/*.yaml ${EXECENV_YML_TMP_FOLDER}

    echo ""
    echo " * Setting parameters for execenv (${i}/${EXEC_ENV_INSTANCES})... "
    EE_NAME="node-"$(cat /proc/sys/kernel/random/uuid | sed 's/[-]//g' | head -c 10)
    EE_NAMES+=( $EE_NAME )
    echo "   "${EE_NAME}

    if [ "${METRICBEAT}" == "no" ]
    then
      echo " * METRICBEAT disabled"
      container_disable ${EXECENV_YML_TMP_FOLDER}/node-0.yaml "METRICBEAT"
    else
      echo " * METRICBEAT enabled"
    fi

    if [ "${FILEBEAT}" == "no" ]
    then
      echo " * FILEBEAT disabled"
      container_disable ${EXECENV_YML_TMP_FOLDER}/node-0.yaml "FILEBEAT"
    else
      echo " * FILEBEAT enabled"
    fi

    if [ "${PACKETBEAT}" == "no" ]
    then
      echo " * PACKETBEAT disabled"
      container_disable ${EXECENV_YML_TMP_FOLDER}/node-0.yaml "PACKETBEAT"
    else
      echo " * PACKETBEAT enabled"
    fi 

    if [ "${POLYCUBE}" == "no" ]
    then
      if [ "${PROBE}" == "no" ]
      then
        echo " * POLYCUBE disabled"
        container_disable ${EXECENV_YML_TMP_FOLDER}/node-0.yaml "POLYCUBE"
      fi
    else
      echo " * POLYCUBE enabled"
    fi

    if [ "${PROBE}" == "no" ]
    then
      echo " * PROBE disabled"
      # POLYCUBE container is managed by "POLYCUBE" case
      #container_disable ${EXECENV_YML_TMP_FOLDER}/node-0.yaml "POLYCUBE"
      container_disable ${EXECENV_YML_TMP_FOLDER}/node-0.yaml "SCHEDULER"
      container_disable ${EXECENV_YML_TMP_FOLDER}/node-0.yaml "LOGSTASH"
    else
      echo " * PROBE enabled"
    fi

    sed -i "s/node-0/${EE_NAME}/" ${EXECENV_YML_TMP_FOLDER}/*.yaml
    sed -i "s;_FILEBEAT_LOG_DATA_PATH_;${FILEBEAT_LOG_DATA_PATH};" ${EXECENV_YML_TMP_FOLDER}/*.yaml
    echo " * Deploying execenv..."
    kubectl apply -f ${EXECENV_YML_TMP_FOLDER}/node-0-storage.yaml
    kubectl apply -f ${EXECENV_YML_TMP_FOLDER}/node-0-configmap.yaml
    kubectl apply -f ${EXECENV_YML_TMP_FOLDER}/node-0.yaml
    kubectl apply -f ${EXECENV_YML_TMP_FOLDER}/node-0-service.yaml

    echo " * Check POD status ..."
    checkPod $EE_NAME

    CB_POD_INSTANCE_NAME=$(kubectl get pods --all-namespaces | grep context-broker | awk '{ print $2 }')
    echo " * Setting LCP ..."
#   kubectl exec -it --namespace=${CB_NAMESPACE} ${CB_POD_INSTANCE_NAME} -c elasticsearch -- bash -c "curl -XPOST -H 'Content-Type: application/json' -H \"${CB_AUTH_KEY}\" cb-manager-service:5000/type/exec-env -d $(exec_env_types)" 
    
    kubectl exec -it --namespace=${CB_NAMESPACE} ${CB_POD_INSTANCE_NAME} -c elasticsearch -- bash -c "curl -XPOST -H 'Content-Type: application/json' -H \"${CB_AUTH_KEY}\" cb-manager-service:5000/exec-env -d $(exec_env)" > /dev/null 

  done

  echo " * Deployed execenv: "
  for NAME in ${EE_NAMES[@]};
  do
    echo "    ${NAME}"
  done

fi





