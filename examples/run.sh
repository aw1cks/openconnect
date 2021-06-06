#!/bin/sh

set -e

SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")
. "${SCRIPT_PATH}/env"

sudo docker run --rm -d \
--cap-add NET_ADMIN \
--name "${CONTAINER_NAME}" \
-p 127.0.0.1:53:53/udp \
-e URL="${URL}" \
-e USER="${USER}" \
-e AUTH_GROUP="${AUTH_GROUP}" \
-e PASS="${PASS}" \
-e OTP="${OTP}" \
-e SEARCH_DOMAINS="${SEARCH_DOMAINS}" \
docker.io/aw1cks/openconnect

CONTAINER_GW=$(sudo docker inspect "${CONTAINER_NAME}" | jq -r '.[0].NetworkSettings.Networks.bridge.IPAddress')
# shellcheck disable=SC2153
for ROUTE in ${ROUTES}
do
  sudo ip route add "${ROUTE}" via "${CONTAINER_GW}"
done
