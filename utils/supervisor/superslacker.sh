#!/bin/bash
# Copyright (c) ASTRID 2020-2022
# author: Alex Carrega <alessandro.carrega@cnit.it>

if [ -z "$SLACK_WEBHOOK_URL" ]; then
    echo "Error: SLACK_WEBHOOK_URL not defined"
    exit 1
fi

superslacker --webhook="$SLACK_WEBHOOK_URL" --hostname="cb.astrid.openstack.cnit" --events="STOPPED,STARTING,RUNNING,BACKOFF,STOPPING,EXITED,FATAL,UNKNOWN" --user="astrid-project"
