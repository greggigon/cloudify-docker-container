#!/bin/bash

echo '*************************************'
echo $0
echo '*************************************'

VERSION='3.1m4'
PLUGIN_VERSION='1.1m4'

UI_URL='http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/3.1.0/m5-RELEASE/cloudify-ui_3.1.0-m5-b82_amd64.deb'
UI_PACKAGE='cloudify-ui_3.1.0-m5-b82_amd64.deb'
UI_VERSION='3.1.0-m5'

UBUNTU_AGENT_URL='http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/3.1.0/m4-RELEASE/cloudify-ubuntu-agent_3.1.0-m4-b81_amd64.deb'
UBUNTU_AGENT_PACKAGE='cloudify-ubuntu-agent_3.1.0-m4-b81_amd64.deb'

WINDOWS_AGENT_URL='http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/3.1.0/m4-RELEASE/cloudify-windows-agent_3.1.0-m4-b81_amd64.deb'
WINDOWS_AGENT_PACKAGE='cloudify-windows-agent_3.1.0-m4-b81_amd64.deb'

apt-get -y install python-dev libyaml-cpp-dev
# Now for the manager
pip install virtualenv

echo '********************** Getting Cloudify sources and stuff *********************'
mkdir -p /opt/cloudify-repos/$VERSION
cd /opt/cloudify-repos/$VERSION

wget https://github.com/cloudify-cosmo/cloudify-rest-client/archive/$VERSION.zip
unzip $VERSION.zip
rm -rf $VERSION.zip

wget https://github.com/cloudify-cosmo/cloudify-manager/archive/$VERSION.zip
unzip $VERSION.zip
rm -rf $VERSION.zip

wget https://github.com/cloudify-cosmo/cloudify-plugins-common/archive/$VERSION.zip
unzip $VERSION.zip
rm -rf $VERSION.zip

wget https://github.com/cloudify-cosmo/cloudify-dsl-parser/archive/$VERSION.zip
unzip $VERSION.zip
rm -rf $VERSION.zip

wget https://github.com/cloudify-cosmo/cloudify-amqp-influxdb/archive/$VERSION.zip
unzip $VERSION.zip
rm -rf $VERSION.zip

echo '**************************** Installing manager worker ****************************'

mkdir -p /opt/cloudify/celery/cloudify.management__worker
cd /opt/cloudify/celery/cloudify.management__worker
virtualenv env
. env/bin/activate
pip install celery==3.0.24

cd /opt/cloudify-repos/$VERSION/cloudify-rest-client-$VERSION/
pip install .

cd /opt/cloudify-repos/$VERSION/cloudify-plugins-common-$VERSION/
pip install .

cd /opt/cloudify-repos/$VERSION/cloudify-manager-$VERSION/plugins/agent-installer
pip install .

cd /opt/cloudify-repos/$VERSION/cloudify-manager-$VERSION/plugins/plugin-installer
pip install .

cd /opt/cloudify-repos/$VERSION/cloudify-manager-$VERSION/plugins/windows-agent-installer
pip install .

cd /opt/cloudify-repos/$VERSION/cloudify-manager-$VERSION/plugins/windows-plugin-installer
pip install .

cd /opt/cloudify-repos/$VERSION/cloudify-manager-$VERSION/plugins/riemann-controller
pip install .

cd /opt/cloudify-repos/$VERSION/cloudify-manager-$VERSION/workflows
pip install .

cd /opt/cloudify-repos/$VERSION/cloudify-dsl-parser-$VERSION
pip install .


echo '********************** Setting up celery worker *********************'
cp /tmp/config-manager/manager-worker/runceleryd.sh /opt/cloudify/celery/cloudify.management__worker/env/bin/

mkdir -p /etc/service/cfy-celery/
cp /tmp/config-manager/manager-worker/run /etc/service/cfy-celery/
cp /tmp/config-manager/manager-worker/finish /etc/service/cfy-celery/
chmod +x /etc/service/cfy-celery/run
chmod +x /etc/service/cfy-celery/finish


echo '********************** Now for the REST Manager *********************'
cd /opt/cloudify
virtualenv manager
. manager/bin/activate

cd /opt/cloudify-repos/$VERSION/cloudify-dsl-parser-$VERSION
pip install .

cd /opt/cloudify-repos/$VERSION/cloudify-manager-$VERSION/rest-service/
# TODO: try to remove it, figure out the way to use PIP instead of Python
sed -i "s/flask-restful==0.2.5/flask-restful==0.2.12/g" setup.py
python setup.py install

cd /opt/cloudify-repos/$VERSION/cloudify-amqp-influxdb-$VERSION/
pip install .

mkdir -p /opt/cloudify/manager/resources/packages
mkdir -p /opt/cloudify/manager/conf
cp /opt/cloudify-repos/$VERSION/cloudify-manager-$VERSION/resources/rest-service/* /opt/cloudify/manager/resources -R

cp /tmp/config-manager/rest/guni.conf /opt/cloudify/manager/conf
cp /tmp/config-manager/rest/runmanager.sh /opt/cloudify/manager/bin
cp /opt/cloudify-repos/$VERSION/cloudify-manager-$VERSION/rest-service/manager_rest /opt/cloudify/manager/ -R

mkdir -p /etc/service/cfy-rest/
cp /tmp/config-manager/rest/run /etc/service/cfy-rest/
chmod +x /etc/service/cfy-rest/run

mkdir -p /etc/service/cfy-amqp-influx/
cp /tmp/config-manager/amqp-influx/run /etc/service/cfy-amqp-influx/
chmod +x /etc/service/cfy-amqp-influx/run

echo '********************** Now for the Cloudify UI *********************'
cd /tmp

echo 'Intalling Grafana now ... wait'
wget $UI_URL --quiet

dpkg -x cloudify-ui_3.1.0-m4-b81_amd64.deb ./cosmo-ui
mkdir -p /opt/cloudify/grafana
cd ./cosmo-ui/packages/cloudify-ui
tar -zxf grafana*
mv ./package/* /opt/cloudify/grafana
cp ./config/grafana/config.js /opt/cloudify/grafana

npm install -d cosmo-ui-$UI_VERSION.tgz

tar -zxf cosmo-ui-$UI_VERSION.tgz
mkdir -p /opt/cloudify/ui
mv node_modules/ /opt/cloudify/ui/

mkdir -p /etc/service/cfy-ui/
cp /tmp/config-manager/ui/run /etc/service/cfy-ui/
chmod +x /etc/service/cfy-ui/run
sed -i "s/\"cosmoPort\": 80/\"cosmoPort\": 8180/g" /opt/cloudify/ui/node_modules/cosmo-ui/backend/gsPresets.json
sed -i "s/cosmoPort: 80/cosmoPort: 8180/g" /opt/cloudify/ui/node_modules/cosmo-ui/backend/appConf.js

cp /tmp/config-manager/ui/settings.json /opt/cloudify/ui/node_modules/cosmo-ui/backend/

echo '************************ Last bit is the Cloudify bootstrapping ************************'
mkdir -p /etc/service/cfy-bootstrap
cp /tmp/config-manager/bootstraping/run /etc/service/cfy-bootstrap
chmod +x /etc/service/cfy-bootstrap/run

# Copy Rieamnn config file
cp -f /opt/cloudify-repos/$VERSION/cloudify-manager-$VERSION/plugins/riemann-controller/riemann_controller/resources/manager.config /etc/riemann/riemann.config


# Add ubuntu Agent resources
echo 'Preaparing super special Ubuntu Agent now ...'

cd /tmp

wget $UBUNTU_AGENT_URL --quiet
dpkg -x $UBUNTU_AGENT_PACKAGE ./ubuntu-agent

mkdir -p /opt/cloudify/manager/resources/packages/scripts/
mv ./ubuntu-agent/agents/Ubuntu-agent/config/Ubuntu-agent-disable-requiretty.sh /opt/cloudify/manager/resources/packages/scripts/

mkdir -p /opt/cloudify/manager/resources/packages/templates/
mv ./ubuntu-agent/agents/Ubuntu-agent/config/Ubuntu-celeryd-cloudify.conf.template /opt/cloudify/manager/resources/packages/templates/
mv ./ubuntu-agent/agents/Ubuntu-agent/config/Ubuntu-celeryd-cloudify.init.template /opt/cloudify/manager/resources/packages/templates/

mkdir -p /opt/cloudify/manager/resources/packages/agents/
mv ./ubuntu-agent/agents/Ubuntu-agent/Ubuntu-agent.tar.gz /opt/cloudify/manager/resources/packages/agents/
rm -rf $UBUNTU_AGENT_PACKAGE ./ubuntu-agent

wget $WINDOWS_AGENT_URL --quiet
dpkg -x $WINDOWS_AGENT_PACKAGE ./windows-agent

mv ./windows-agent/agents/windows-agent/Cloudify.exe /opt/cloudify/manager/resources/packages/agents/CloudifyWindowsAgent.exe
rm -rf $WINDOWS_AGENT_PACKAGE ./windows-agent

mkdir Ubuntu-agent
cd Ubuntu-agent
	virtualenv env
	. env/bin/activate
cd /tmp

pip install celery==3.0.24
pip install pyzmq==14.3.1

pushd /opt/cloudify-repos/$VERSION/
	pushd cloudify-rest-client-$VERSION 
		pip install .
	popd
	pushd cloudify-plugins-common-$VERSION
		pip install .
	popd
	pushd cloudify-manager-$VERSION
		pushd plugins/plugin-installer
          pip install .
        popd
        pushd plugins/agent-installer
          pip install .
        popd
        pushd plugins/windows-agent-installer
          pip install .
        popd
        pushd plugins/windows-plugin-installer
          pip install .
        popd
    popd
popd

cd /tmp/

pip install https://github.com/cloudify-cosmo/cloudify-script-plugin/archive/$PLUGIN_VERSION.zip
pip install https://github.com/cloudify-cosmo/cloudify-diamond-plugin/archive/$PLUGIN_VERSION.zip

tar -czf Ubuntu-agent.tar.gz ./Ubuntu-agent/
mv Ubuntu-agent.tar.gz /opt/cloudify/manager/resources/packages/agents/
deactivate
rm -rf /tmp/Ubuntu-agent/

mkdir /keys

echo '************************ CLEANING ************************'

rm -rf logstash*
rm -rf cosmo-ui*
rm -rf kibana*
rm -rf /tmp/config*

echo '************************ DONE ************************'
echo 'Remember to map ports when you run container'