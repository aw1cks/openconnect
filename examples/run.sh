#!/bin/sh

set -e

SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")
# shellcheck disable=SC1091
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

RESOLV_CONFIG=$(grep -v '^nameserver' /etc/resolv.conf | grep -v search)
ORIGINAL_SEARCH_DOMAINS=$(grep '^search' /etc/resolv.conf)
NEW_SEARCH_DOMAINS="${ORIGINAL_SEARCH_DOMAINS} ${SEARCH_DOMAINS}"
NEW_NAMESERVER_CONF='nameserver 127.0.0.1'
sudo cp /etc/resolv.conf /etc/resolv.conf.orig
printf "%s\n%s\n%s\n" "${RESOLV_CONFIG}" "${NEW_SEARCH_DOMAINS}" "${NEW_NAMESERVER_CONF}" | sudo tee /etc/resolv.conf &> /dev/null
