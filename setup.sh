#!/bin/bash
# NOTE: things added here MUST be idempotent

set -euo pipefail

thisdir="$(realpath "$(dirname "$0")")"
cd "$thisdir"

mkdir -p /srv/map_cache/maps

pushd systemd
for service in *; do
	echo "$service"
	cp "$thisdir"/systemd/"$service" /etc/systemd/system/
done

systemctl daemon-reload

systemctl enable --now tf2-fastdl.service
systemctl enable tf2-walkway.timer
systemctl enable tf2-community.timer
systemctl enable tf2-dodgeball.timer

# [] place services/timer
# [] enable services
