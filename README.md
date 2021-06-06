# OpenConnect Docker container

## Why?

OpenConnect doesn't ship with any init scripts or systemd units.
It's also not easy to non-interactively provide username, password and especially OTP.
Additionally, running in a docker container gives some extra flexibility with routing.

## Example usage

To run the container:

```shell
docker run -d \
--cap-add NET-ADMIN \
-e URL=https://myvpn.com/anyconnect \
-e USER=myuser \
-e AUTH_GROUP=mygroup \
-e PASS=mypassword \
-e OTP=123456 \
-e EXTRA_ARGS="--protocol=anyconnect" \
-e SEARCH_DOMAINS="my.corporate-domain.com subdomain.my.corporate-domain.com" \
docker.io/aw1cks/openconnect'
```

The provided helper scripts in `examples/` will create the container for you and set up the routing table appropriately.

The helper scripts have the following requirements:
 - `docker`
 - `sudo` (and permissions to run `ip` and `docker` as root)
 - `iproute2`
 - `jq`

To use the helper scripts, do the following:

```shell
$ cd $(git rev-parse --show-cdup)
$ cp examples/* .
$ $EDITOR env # set your values here
$ ./run.sh
$ ./stop.sh # Tears down the container and cleans up the routing table
```

## Building the container yourself

The following build args are used:

 - `BUILD_DATE` (RFC3339 timestamp)
 - `COMMIT_SHA` (commit hash from which image was built)

```shell
docker build \
  --build-arg BUILD_DATE="$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
  --build-arg COMMIT_SHA="$(git rev-parse HEAD 2>/dev/null || echo 'null')" \
  -t openconnect .
```

## Known issues

When running not in privileged mode, OpenConnect gives errors such as this:

`Cannot open "/proc/sys/net/ipv4/route/flush"`

This is normal and does not impact the operation of the VPN.

To suppress these errors, run with `--privileged`.
