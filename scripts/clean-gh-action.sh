#!/bin/#!/bin/bash

user=astrid-project
repo=astrid-framework

gh api repos/$user/$repo/actions/runs \
    --paginate -q '.workflow_runs[] | "\(.id)"' | \
    xargs -I % gh api repos/$user/$repo/actions/runs/% -X DELETE
