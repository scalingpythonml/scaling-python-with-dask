#!/usr/bin/env bash 

curl -H "Accept: application/vnd.github.everest-preview+json" -H "Authorization: token ${GH_PAT}" --request POST  --data '{"event_type": "update-event"}' https://api.github.com/repos/${PIPELINE_ORG_NAME}/${PIPELINE_REPO_NAME}/dispatches
echo "triggered an update-event"


