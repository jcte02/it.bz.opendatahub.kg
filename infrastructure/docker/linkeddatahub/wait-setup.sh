#!/bin/bash

while [ ! -f "/var/linkeddatahub/ssl/.setup-done" ]
do
  sleep 1
  echo "Waiting setup to complete"
done

./entrypoint.sh
