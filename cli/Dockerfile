FROM ubuntu:precise
MAINTAINER Greg Gigon <gigong@rbs.com>

ENV http_proxy http://storv11088:8008
ENV https_proxy http://storv11088:8008
ENV TERM xterm
ENV home /root
ENV VERSION 3.1m4


RUN apt-get update && apt-get -y install wget python2.7 python-pip python-dev unzip && cd /tmp && wget --no-check-certificate https://github.com/cloudify-cosmo/cloudify-dsl-parser/archive/$VERSION.zip && unzip $VERSION.zip && rm $VERSION.zip \
	&& wget --no-check-certificate https://github.com/cloudify-cosmo/cloudify-rest-client/archive/$VERSION.zip && unzip $VERSION.zip && rm $VERSION.zip \
	&& wget --no-check-certificate https://github.com/cloudify-cosmo/cloudify-plugins-common/archive/$VERSION.zip && unzip $VERSION.zip && rm $VERSION.zip \
	&& wget --no-check-certificate https://github.com/cloudify-cosmo/cloudify-cli/archive/$VERSION.zip && unzip $VERSION.zip && rm $VERSION.zip \
	&& cd /tmp/cloudify-rest-client-$VERSION && pip install . \
	&& cd /tmp/cloudify-plugins-common-$VERSION && pip install . \
	&& cd /tmp/cloudify-dsl-parser-$VERSION && pip install . \
	&& cd /tmp/cloudify-cli-$VERSION && sed -i 's/REST_PORT = 80/REST_PORT = 8180/g' cloudify_cli/constants.py && pip install . \
	&& rm -rf /tmp/cloudify*
	
VOLUME /blueprints
