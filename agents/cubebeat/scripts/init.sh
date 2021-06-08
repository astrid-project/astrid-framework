#!bin/bash
# ASTRID - Cubebeat
# author: Alex Carrega <alessandro.carrega@cnit.it>

# Download the source, build the component and copy the configuration files

WORK_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$WORK_PATH/vars.sh"

mkdir -p $COMMANDS_PATH
ln -fs $WORK_PATH $COMMANDS_PATH/$COMPONENT

if [ "$1" == "-nc" ] || [ "$1" == "--no-cache" ] || [ ! -d "$GOPATH/src/gitlab.com/$PROJECT-repositories/$COMPONENT" ]; then
    rm -rf "$GOPATH/src/gitlab.com/$PROJECT-repositories/$COMPONENT"
    git clone "https://github.com/$PROJECT-project/$COMPONENT" --branch "$VERSION" "$GOPATH/src/gitlab.com/$PROJECT-repositories/$COMPONENT"
else
    git pull
fi

rm -rf "$INSTALLATION_PATH"
mkdir -p "$INSTALLATION_PATH"

cp "$WORK_PATH/../settings/$VERSION/$COMPONENT.yml" "$INSTALLATION_PATH/"

cd "$GOPATH/src/gitlab.com/$PROJECT-repositories/$COMPONENT"
bash ./build.sh

cp "./$COMPONENT" "$INSTALLATION_PATH/"
