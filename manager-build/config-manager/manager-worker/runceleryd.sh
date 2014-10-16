#!/bin/bash

if [ -z "$MANAGER_IP" ]; then
	echo 'You need to provide MANAGER_IP when you run Manager Celery Worker!'
	exit 1
fi

echo "******************* Starting Celery with Manager IP [$MANAGER_IP] ********************"

cd /opt/cloudify/celery/cloudify.management__worker/env

# activate pyenv environment
. bin/activate

export MANAGEMENT_IP=$MANAGER_IP
export BROKER_URL="amqp://guest:guest@$MANAGER_IP:5672//"
export MANAGEMENT_USER="root"
export MANAGER_REST_PORT="8180"
export CELERY_WORK_DIR="/opt/cloudify/celery/cloudify.management__worker/work"
export IS_MANAGEMENT_NODE="True"
export AGENT_IP="cloudify.management"
# this doesnt seem to resolve to anything
# export CELERY_BASE_DIR="/opt/cloudify/celery/"
export VIRTUALENV="${CELERY_BASE_DIR}"
export MANAGER_FILE_SERVER_URL="http://$MANAGER_IP:53229"
export MANAGER_FILE_SERVER_BLUEPRINTS_ROOT_URL="${MANAGER_FILE_SERVER_URL}/blueprints"
export CELERY_TASK_SERIALIZER="json"
export CELERY_RESULT_SERIALIZER="json"
export CELERY_RESULT_BACKEND="amqp://"
export RIEMANN_CONFIGS_DIR="/opt/cloudify/celery/cloudify.management__worker/riemann"

WORKER_LOGS_DIR="/var/log/celery/cloudify.management__worker/work/"

mkdir -p $WORKER_LOGS_DIR

python -m celery.bin.celeryd \
--include=cloudify_system_workflows.deployment_environment,plugin_installer.tasks,worker_installer.tasks,riemann_controller.tasks,cloudify.plugins.workflows \
--broker=amqp:// \
-n celery.cloudify.management \
--events \
--app=cloudify \
--loglevel=debug \
-Q cloudify.management \
--logfile=$WORKER_LOGS_DIR/cloudify.management_worker.log --pidfile=$WORKER_LOGS_DIR/cloudify.management_worker.pid \
--autoscale=5,2
