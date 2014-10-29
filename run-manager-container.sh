#!/bin/bash

if [ $# -lt 2 ]; then
	echo "You need to run CFY Manager container with: $0 MANAGER_IP KEYS_FOLDER [optionaly true|false if want to run interactive mode in container, false by default]"
	echo "\n For example: $0 1.1.1.1 /home/path/keys true"
	exit 1
fi

export MANAGER_IP=$1
export KEYS=$2

echo '**********************************************************************'
echo "*********** Running Contianer with IP $MANAGER_IP and /keys mapped to $"
echo '**********************************************************************'

if [ $# -eq 3 ];then
	if [ $3 == 'true' ]; then
		docker run -t -e "http_proxy=" -e "https_proxy=" -e "MANAGER_IP=$MANAGER_IP" -v $KEYS:/keys -p 3000:3000 -p 5672:5672 -p 15672:15672 -p 8086:8086 -p 8083:8083 -p 8100:8100 -p 8180:8180 -p 9001:9001 -p 9200:9200 -p 53229:53229 -i cfy_manager /sbin/my_init -- bash -l
	else 
		docker run -d -e "http_proxy=" -e "https_proxy=" -e "MANAGER_IP=$MANAGER_IP" -v $KEYS:/keys -p 3000:3000 -p 5672:5672 -p 15672:15672 -p 8086:8086 -p 8083:8083 -p 8100:8100 -p 8180:8180 -p 9001:9001 -p 9200:9200 -p 53229:53229 -i cfy_manager /sbin/my_init
	fi
else
	docker run -d -e "http_proxy=" -e "https_proxy=" -e "MANAGER_IP=$MANAGER_IP" -v $KEYS:/keys -p 3000:3000 -p 5672:5672 -p 15672:15672 -p 8086:8086 -p 8083:8083 -p 8100:8100 -p 8180:8180 -p 9001:9001 -p 9200:9200 -p 53229:53229 -i cfy_manager /sbin/my_init
fi
