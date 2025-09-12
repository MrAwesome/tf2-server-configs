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

rsync -aAXvh bin/ /root/bin/
rsync -aAXvh "$thisdir"/systemd/ /etc/systemd/system/
systemctl daemon-reload

pushd systemd

systemctl enable --now tf2-fastdl.service
for timer in *.timer; do
    # NOTE: you may need to --now or start these as well, but at least once that caused an instant server restart so double-check that in the future and verify with list-timers that these are actually running
	systemctl enable "$timer"
done

popd
