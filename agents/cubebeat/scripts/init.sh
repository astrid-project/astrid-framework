#!bin/bash
# ASTRID - Cubebeat
# author: Alex Carrega <alessandro.carrega@cnit.it>

# Download the source, build the component and copy the configuration files

WORK_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$WORK_PATH/vars.sh"

git clone https://github.com/$PROJECT-project/$COMPONENT --branch $VERSION $GOPATH/src/gitlab.com/$PROJECT-repositories/$COMPONENT

cp "$WORK_PATH/../settings/$VERSION/$COMPONENT.yml" $INSTALLATION_PATH/

cd $GOPATH/src/gitlab.com/$PROJECT-repositories/$COMPONENT
./build.sh

cp ./$COMPONENT $INSTALLATION_PATH/
