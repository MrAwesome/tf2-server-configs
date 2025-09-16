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
    # NOTE: this will not start/restart the servers, you will want to manually start tf2-dedicated@<servername> for each of them the first time
	systemctl enable --now "$timer"
done

popd
