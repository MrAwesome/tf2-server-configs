#!/bin/bash

cd /root/docker
if [[ -z "$1" ]]; then
	docker-compose down
	/root/bin/run_server.sh 
else
	docker stop "$1"
	docker remove "$1"
	/root/bin/run_server.sh "$1"
fi
