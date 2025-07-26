#!/bin/bash
# NOTE: things added here MUST be idempotent

set -euo pipefail

thisdir="$(dirname "$0")"
cd "$thisdir"

mkdir -p /srv/map_cache/maps

pushd systemd
for service in *; do
	ln -s "$thisdir"/systemd/"$service" /etc/systemd/system/
done




# [] place services/timer
# [] enable services
