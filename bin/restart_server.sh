#!/bin/bash

set -euxo pipefail

servername="${1:-}"

cd /root/docker
if [[ -z "$servername" ]]; then
	docker-compose down
	/root/bin/run_server.sh 
else
	docker stop "$servername"
	docker remove "$servername"
	/root/bin/run_server.sh "$servername"
fi
