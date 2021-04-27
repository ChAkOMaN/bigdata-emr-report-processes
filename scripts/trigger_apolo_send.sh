#!/bin/bash

TOKEN=c84253769fd835f3484635e0cb437a
REF=master
URI=https://gitlab.platform.xbyorange.com/api/v4/projects/84/trigger/pipeline

if [ "$ENVIRONMENT" = "production" ]; then
  CMD=$(curl -sL -w "\n%{http_code}\n" -X POST -F token=$TOKEN -F ref=$REF $URI | tail -n 1)

  if [ $CMD -ne 201 ]; then
    >&2 echo "trigger pipeline has failed"
    exit -1
  else
    echo trigger call success
  fi
fi
