#!/bin/bash
# NOTE: things added here MUST be idempotent

set -euo pipefail

cd "$(dirname "$0")"

mkdir -p /srv/map_cache/maps

for mapdir in /root/tf2-*/tf/maps/; do
    rsync -avh --progress "$mapdir"/ /srv/map_cache/maps/
done

