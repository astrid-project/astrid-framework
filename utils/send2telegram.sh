#!/bin/bash
# ASTRID
# author: Alex Carrega <alessandro.carrega@cnit.it>

if [ -z "$1" ]; then
    echo "Error: missing message"
    echo "Usage: $0 <message>"
    exit 1
fi

TELEGRAM_TOKEN="1463515955:AAHPW75lMcnOUfD2dZEilrW1d0HwQgcyGt4"
TELEGRAM_CHATID="ASTRID"

curl -s -X POST https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage -d chat_id=$TELEGRAM_CHATID -d text="$1"
