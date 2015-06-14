#! /bin/bash

. ./config.sh

NAME=c1
DOMAIN=weave.local.
HOSTNAME=$NAME-hostname.$DOMAIN

# Docker inspect hostname + domainname of container $2 on host $1
docker_inspect_fqdn() {
    docker_on $1 inspect --format='{{.Config.Hostname}}.{{.Config.Domainname}}' $2
}

# Start container with args $2.. and assert fqdn of $1
assert_expected_fqdn() {
    EXPECTED_FQDN=$1
    shift
    start_container_with_dns $HOST1 "$@"
    assert "docker_inspect_fqdn $HOST1 $NAME" $EXPECTED_FQDN
    docker_on $HOST1 rm -f $NAME >/dev/null
}

start_suite "Use container name as hostname"

weave_on $HOST1 launch -iprange 10.2.0.0/24

assert_expected_fqdn "$NAME.$DOMAIN" --name=$NAME
assert_expected_fqdn "$NAME.$DOMAIN" --name $NAME
assert_expected_fqdn "$HOSTNAME"     --name=$NAME         -h $HOSTNAME
assert_expected_fqdn "$HOSTNAME"     --name=$NAME         --hostname=$HOSTNAME
assert_expected_fqdn "$HOSTNAME"     --name=$NAME         --hostname $HOSTNAME
assert_expected_fqdn "$HOSTNAME"     -h $HOSTNAME         --name=$NAME
assert_expected_fqdn "$HOSTNAME"     --hostname=$HOSTNAME --name=$NAME
assert_expected_fqdn "$HOSTNAME"     --hostname $HOSTNAME --name=$NAME

end_suite
