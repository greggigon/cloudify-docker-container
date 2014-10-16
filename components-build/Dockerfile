FROM phusion/baseimage:latest
MAINTAINER Greg Gigon

ENV TERM xterm
ENV home /root

COPY prepare-components.sh /tmp/
COPY config/ /tmp/config/

RUN /bin/bash /tmp/prepare-components.sh
