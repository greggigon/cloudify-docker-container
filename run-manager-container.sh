#!/bin/bash

if [ $# != 1 ]; 
then
	MANAGER_IP=`/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{print $1}'`
else
	MANAGER_IP=$1
fi


echo '**********************************************************************'
echo "*********** Running Contianer with IP $MANAGER_IP "
echo '**********************************************************************'

docker run -t -e "http_proxy=" -e "https_proxy=" -e "MANAGER_IP=$MANAGER_IP" -p 3000:3000 -p 5672:5672 -p 15672:15672 -p 8086:8086 -p 8083:8083 -p 8100:8100 -p 8180:8180 -p 9001:9001 -p 9200:9200 -p 53229:53229 -i cfy_manager /sbin/my_init -- bash -l 