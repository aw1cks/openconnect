#!/bin/sh

set -e

SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")
# shellcheck disable=SC1091
. "${SCRIPT_PATH}/env"

# Remove our routes first
CONTAINER_GW=$(sudo docker inspect "${CONTAINER_NAME}" | jq -r '.[0].NetworkSettings.Networks.bridge.IPAddress')
# shellcheck disable=SC2153
for ROUTE in ${ROUTES}
do
  sudo ip route del "${ROUTE}" via "${CONTAINER_GW}"
done

# Now, let's tear down the container
sudo docker rm -f "${CONTAINER_NAME}"

# Restore DNS config
sudo mv -f /etc/resolv.conf.orig /etc/resolv.conf &> /dev/null || true
