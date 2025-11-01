#!/bin/bash

set -euxo pipefail

servername="${1:-}"

cd /root/docker
if [[ -z "$servername" ]]; then
    echo "[WARN] Warning! Restarting all servers at once, this is not recommended."
    sleep 4
	docker-compose down
	/root/bin/run_server.sh 
else
	docker stop "$servername"
	docker remove "$servername"
    steamapps="/root/servers/${servername}/steamapps/"
    [[ -d "$steamapps" ]] && rm -rf "$steamapps"
	/root/bin/run_server.sh "$servername"
fi
