#!/bin/bash

TOKEN=506fd816edd94a0f0a5a5edcd4b63d
REF=master
URI=https://gitlab.platform.xbyorange.com/api/v4/projects/83/trigger/pipeline

if [ "$ENVIRONMENT" = "production" ]; then
  CMD=$(curl -sL -w "\n%{http_code}\n" -X POST -F token=$TOKEN -F ref=$REF $URI | tail -n 1)

  if [ $CMD -ne 201 ]; then
    >&2 echo "trigger pipeline has failed"
    exit -1
  else
    echo trigger call success
  fi
fi
