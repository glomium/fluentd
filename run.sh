#!/bin/sh

# parameters
DOCKER_HOST=`netstat -nr | grep '^0\.0\.0\.0' | awk '{print $2}'`

sed "s/{{ *DOCKER_HOST *}}/$DOCKER_HOST/" /etc/fluent/fluent.template > /etc/fluent/fluent.conf

exec fluentd --suppress-config-dump --no-supervisor -q
