#!/bin/bash

mkdir -p $PWD/blueprints
docker run -t -v $PWD/blueprints/:/blueprints -i cfy_cli /bin/bash -l