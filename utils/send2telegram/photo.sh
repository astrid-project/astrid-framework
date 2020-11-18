#!/bin/bash
# ASTRID
# author: Alex Carrega <alessandro.carrega@cnit.it>

usage () {
    echo "Usage: $0 <photo> [<caption>]"
    exit $1
}

if [ -z "$1" ]; then
    echo "Error: missing photo"
    usage 1
fi

if [ ! -f "$1" ]; then
    echo "Error: photo not found"
    usage 2
fi

TELEGRAM_TOKEN="1463515955:AAHPW75lMcnOUfD2dZEilrW1d0HwQgcyGt4"
TELEGRAM_CHATID="429595417"

curl -s -X POST https://api.telegram.org/bot$TELEGRAM_TOKEN/sendPhoto -F chat_id=$TELEGRAM_CHATID -F photo="@$1" -d caption="$2"
