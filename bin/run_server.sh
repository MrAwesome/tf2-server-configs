#!/bin/bash

set -euxo pipefail

servername="${1:-}"

cd /root/docker

if [[ -z "$servername" ]]; then
	docker-compose up -d
else
	docker-compose up -d "$servername"
fi
