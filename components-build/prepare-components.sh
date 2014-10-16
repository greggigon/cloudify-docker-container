#!/bin/bash

# Components location outside Aptitude repository
ELASTICSEARCH_URL='https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.3.4.deb'
ELASTICSEARCH_PACKAGE='elasticsearch-1.3.4.deb'

RIEMANN_URL='http://aphyr.com/riemann/riemann_0.2.6_all.deb'
RIEMANN_PACKAGE='riemann_0.2.6_all.deb'

LOGSTASH_URL='https://download.elasticsearch.org/logstash/logstash/logstash-1.4.2.tar.gz'
LOGSTASH_PACKAGE='logstash-1.4.2.tar.gz'

KIBANA_URL='https://download.elasticsearch.org/kibana/kibana/kibana-3.1.1.tar.gz'
KIBANA_PACKAGE='kibana-3.1.1.tar.gz'

INFLUX_URL='http://s3.amazonaws.com/influxdb/influxdb_0.8.3_amd64.deb'
INFLUX_PACKAGE='influxdb_0.8.3_amd64.deb'

# Starting with Erlang
curl http://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb -o /tmp/erlang-solutions_1.0_all.deb --silent
sudo dpkg -i /tmp/erlang-solutions_1.0_all.deb
rm -rf /tmp/erlang-solutions_1.0_all.deb

# First get Python 2.7
apt-get update 
apt-get -y install openjdk-7-jdk python2.7 python-dev libyaml-cpp-dev python-pip erlang libpython2.7-dev wget curl zip

rm -rf /etc/service/cron 

cd /tmp

# So, Elasticsearch goes first
echo "Downloading Elasticsearch now ... wait"
wget $ELASTICSEARCH_URL --no-check-certificate --quiet
dpkg -i $ELASTICSEARCH_PACKAGE

mkdir /etc/service/elasticsearch
cp /tmp/config/elasticsearch/run /etc/service/elasticsearch/
chmod +x /etc/service/elasticsearch/run
rm -rf /tmp/elasticsearch*

echo "Installing RabbitMQ now ... wait"
# Now, we install RabbitMQ
apt-get -y install rabbitmq-server
rabbitmq-plugins enable rabbitmq_management
rabbitmq-plugins enable rabbitmq_tracing

mkdir /etc/service/rabbitmq/
cp /tmp/config/rabbitmq/run /etc/service/rabbitmq/
cp /tmp/config/rabbitmq/finish /etc/service/rabbitmq/
cp /tmp/config/rabbitmq/rabbitmq.config /etc/rabbitmq/

chmod +x /etc/service/rabbitmq/run
chmod +x /etc/service/rabbitmq/finish

# Riemann now
echo "Downloading Riemann now ... wait"
wget $RIEMANN_URL --no-check-certificate --quiet
dpkg -i $RIEMANN_PACKAGE

mkdir /etc/service/riemann
cp /tmp/config/riemann/run /etc/service/riemann
chmod +x /etc/service/riemann/run
rm -rf /etc/riemann/rieman.config
rm -rf $RIEMANN_PACKAGE
wget https://s3-eu-west-1.amazonaws.com/gigaspaces-repository-eu/langohr/2.11.0/langohr.jar --no-check-certificate -O /usr/lib/riemann/langohr.jar

# Logstash now
echo "Downloading Logstash now ... wait"
wget $LOGSTASH_URL --no-check-certificate --quiet
tar -zxf $LOGSTASH_PACKAGE
mv logstash-1.4.2 /opt/

mkdir /etc/logstash
cp /tmp/config/logstash/logstash.conf /etc/logstash

mkdir /etc/service/logstash
cp /tmp/config/logstash/run /etc/service/logstash
chmod +x /etc/service/logstash/run

# Kibana to the rescue
echo 'Downloading Kibana now ... wait'
wget $KIBANA_URL --no-check-certificate --quiet
tar -zxf $KIBANA_PACKAGE 
mv kibana-3.1.1 /opt
ln -s /opt/kibana-3.1.1 /opt/kibana3

# Installing NginX now
echo 'Installing NginX now ... wait'
apt-get -y install nginx
cp /tmp/config/nginx/default.conf /etc/nginx/conf.d/
rm -rf /etc/nginx/sites-enabled/default
cp /tmp/config/nginx/default /etc/nginx/sites-enabled/


mkdir /etc/service/nginx
cp /tmp/config/nginx/run /etc/service/nginx/
chmod +x /etc/service/nginx/run

# Installing NodeJS now
echo 'Installing NodeJS now ... wait'
apt-get -y install nodejs npm

# Installing InfluxDB
echo 'Installing InfluxDB now ... wait'
cd /tmp

wget $INFLUX_URL --quiet
dpkg -i $INFLUX_PACKAGE

mkdir /etc/service/influxdb
cp /tmp/config/influxdb/run /etc/service/influxdb/
chmod +x /etc/service/influxdb/run

rm -rf $INFLUX_PACKAGE

