#!/bin/bash

cd /opt/cloudify/manager
. bin/activate
cd manager_rest


export MANAGER_REST_CONFIG_PATH=/opt/cloudify/manager/conf/guni.conf
export WORKERS=$(($(nproc)*2+1))

LOGS_FOLDER=/var/log/cloudify-rest
mkdir -p $LOGS_FOLDER

echo "Starting Gunicorn now ..."

gunicorn  -w ${WORKERS} -b 0.0.0.0:8100 --access-logfile $LOGS_FOLDER/access.log --error-logfile $LOGS_FOLDER/error.log -p $LOGS_FOLDER/manager.pid --log-level info --timeout 300 server:app
