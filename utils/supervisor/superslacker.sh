#!/bin/bash
# Copyright (c) ASTRID 2020-2022
# author: Alex Carrega <alessandro.carrega@cnit.it>

DATE=$(date)
SLACK_WEBHOOK_FILE="/home/debian/.slack_webhook_url"

if [ ! -f "$SLACK_WEBHOOK_FILE" ]; then
    echo "[$DATE] Error: SLACK_WEBHOOK_FILE not found"
    exit 1
fi

SLACK_WEBHOOK_URL="$(cat $SLACK_WEBHOOK_FILE)"

if [ -z "$SLACK_WEBHOOK_URL" ]; then
    echo "[$DATE] Error: SLACK_WEBHOOK_URL not defined"
    exit 2
fi

echo "[$DATE] Start superslacker"
superslacker --webhook="$SLACK_WEBHOOK_URL" --hostname="cb.guard.openstack.cnit" --events="STOPPED,STARTING,RUNNING,BACKOFF,STOPPING,EXITED,FATAL,UNKNOWN" --user="guard-project" --channel="dev"
