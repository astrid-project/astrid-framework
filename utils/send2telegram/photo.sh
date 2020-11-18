#!/bin/bash
# GUARD
# author: Alex Carrega <alessandro.carrega@cnit.it>


if [ -z "$1" ]; then
    echo "Error: missing photo"
    echo "Usage: $0 <photo>"
    exit 1
fi

if [ ! -f "$1" ]; then
    echo "Error: photo not found"
    echo "Usage: $0 <photo>"
    exit 2
fi

TELEGRAM_TOKEN="1497122456:AAGTGBVbOmzmuMFL3Fy80GNM_D5n1qQQvu0"
TELEGRAM_CHATID="429595417"

curl -s -X POST https://api.telegram.org/bot$TELEGRAM_TOKEN/sendPhoto -F chat_id=$TELEGRAM_CHATID -F photo="@$1"
