#!/bin/bash

ASTRID_CONTROLLER_DIRECTORY="astrid-controller"
ASTRID_CONTROLLER_NAME="astrid-controller_web"

astrid-controller-docker-image()
{
  cd $BASE_PATH
  # if Astrid Controller folder doesn't exist, download and compile it
  if [ ! -f "${ASTRID_CONTROLLER_DIRECTORY}" ]
  then
    echo " * Astrid Controller directory doesn't exist."
    echo " * Downloading Astrid Controller code ..."
    git clone https://github.com/astrid-project/astrid-controller.git
    cd $ASTRID_CONTROLLER_DIRECTORY
    echo " * Building Astrid Controller docker image ..."
    docker-compose build
  else
    echo " * Astrid Controller directory exist "
  fi

  # check if Astrid Controller docker image exists
  ASTRID_CONTROLLER_CHECK=$(docker image list | grep astrid-controller | awk '{ print $1 }')
  if [ "${ASTRID_CONTROLLER_CHECK}" = "${ASTRID_CONTROLLER_NAME}" ]
  then
    echo " * Astrid Controller image created "
  else
    echo " ERROR: Astrid Controller image not created "
    return 1
  fi
}

astrid-controller-k8s-deployment()
{
  cd $BASE_PATH
  echo " * Deploying Astrid Controller ..."
  kubectl apply -f $ASTRID_CONTROLLER_DIRECTORY/web-deployment.yaml
  echo " * Deploying Astrid Controller Service ..."
  kubectl apply -f $ASTRID_CONTROLLER_DIRECTORY/web-service.yaml

  while [ true ]
  do
    ASTRID_CONTROLLER_CHECK=$(kubectl get pods --all-namespaces | grep "controller-deployment" | awk '{ print $4}' )
    if [ "${ASTRID_CONTROLLER_CHECK}" = "Running" ]
    then
      echo " * Astrid Controller is in running state"
      break
    else
      echo -n "."
    fi
    sleep 5
  done
}
