#!/bin/bash
# Copyright (c) ASTRID 2020-2022
# author: Alex Carrega <alessandro.carrega@cnit.it>

DATE=$(date)

if [ -z "$SLACK_WEBHOOK_URL" ]; then
    echo "[$DATE] Error: SLACK_WEBHOOK_URL not defined"
    exit 1
fi

echo "[$DATE] Start superslacker"
superslacker --webhook="$SLACK_WEBHOOK_URL" --hostname="cb.astrid.openstack.cnit" --events="STOPPED,STARTING,RUNNING,BACKOFF,STOPPING,EXITED,FATAL,UNKNOWN" --user="astrid-project"
