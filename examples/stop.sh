#!/bin/sh

set -e

SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")
. "${SCRIPT_PATH}/env"

# Remove our routes first
CONTAINER_GW=$(sudo docker inspect "${CONTAINER_NAME}" | jq -r '.[0].NetworkSettings.Networks.bridge.IPAddress')
for ROUTE in ${ROUTES}
do
  sudo ip route del "${ROUTE}" via "${CONTAINER_GW}"
done

# Now, let's tear down the container
sudo docker rm -f "${CONTAINER_NAME}"
