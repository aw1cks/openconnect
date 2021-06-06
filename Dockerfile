FROM docker.io/alpine:3.13
LABEL maintainer='Alex Wicks <alex@awicks.io>'

# BUILD_DATE="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
# COMMIT_SHA="$(git rev-parse HEAD 2>/dev/null || echo 'null')"
ARG BUILD_DATE COMMIT_SHA

# http://label-schema.org/rc1/
LABEL org.label-schema.schema-version='1.0' \
      org.label-schema.name='anyconnect-docker' \
      org.label-schema.build-date="${BUILD_DATE}" \
      org.label-schema.description='AnyConnect-compatible client to route host traffic' \
      org.label-schema.version='1.0' \
      org.label-schema.vcs-url='https://github.com/aw1cks/anyconnect-docker' \
      org.label-schema.vcs-ref="${COMMIT_SHA}"
LABEL org.label-schema.docker.cmd='\
docker run -d \
--cap-add NET-ADMIN \
-e URL=https://myvpn.com/anyconnect \
-e USER=myuser \
-e AUTH_GROUP=mygroup \
-e PASS=mypassword \
-e OTP=123456 \
-e EXTRA_ARGS="--protocol=anyconnect" \
-e SEARCH_DOMAINS="my.corporate-domain.com subdomain.my.corporate-domain.com" \
aw1cks/openconnect'
LABEL org.label-schema.docker.params='\
URL=URL of VPN,USER=username to login to VPN with,\
USER=User to authenticate to VPN with,\
PASS=password for VPN user,\
AUTH_GROUP=Authentication group for VPN login (optional),\
OTP=2FA code (optional),\
EXTRA_ARGS=Any extra arguments to pass to openconnect (optional),\
SEARCH_DOMAINS=Space-separated list of search domains to forward - Only DNS requests to these domains will be forwarded to VPN-configured DNS servers to prevent DNS leaks (optional)'

RUN apk add --no-cache openconnect dnsmasq

WORKDIR /vpn
COPY ./entrypoint.sh .

HEALTHCHECK --start-period=15s --retries=1 \
  CMD pgrep openconnect || exit 1; pgrep dnsmasq || exit 1

ENTRYPOINT ["/vpn/entrypoint.sh"]
