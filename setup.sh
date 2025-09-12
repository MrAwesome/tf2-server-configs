#!/bin/bash
# NOTE: things added here MUST be idempotent

set -euo pipefail

if [[ ! -f /root/docker/docker-compose.yml ]]; then
	echo "This script requires a /root/docker/docker-compose.yml to be present!"
	exit 1
fi

thisdir="$(realpath "$(dirname "$0")")"
cd "$thisdir"

mkdir -p /srv/map_cache/maps
mkdir -p /root/bin

cp bin/* /root/bin/

rsync -aAXvh "$thisdir"/systemd/ /etc/systemd/system/

systemctl daemon-reload

systemctl enable --now tf2-fastdl.service
for timer in *.timer; do
	systemctl enable "$timer"
done
