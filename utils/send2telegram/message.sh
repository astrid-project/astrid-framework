#!/bin/bash
# GUARD
# author: Alex Carrega <alessandro.carrega@cnit.it>


if [ -z "$1" ]; then
    echo "Error: missing message"
    echo "Usage: $0 <message>"
    exit 1
fi

TELEGRAM_TOKEN="1497122456:AAGTGBVbOmzmuMFL3Fy80GNM_D5n1qQQvu0"
TELEGRAM_CHATID="429595417"

curl -s -X POST https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage -d chat_id=$TELEGRAM_CHATID -d text="$1"
