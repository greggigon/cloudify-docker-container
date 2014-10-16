Cloudify Docker Container
=========================

[Docker](http://docker.io "Docker") files that prepare [Cloudify 3.x](http://getcloudify.org "Cloudify 3.x") to run as a Docker Container.

> The master branch builds Container with Cloudify version **3.1m4**.

The base image for Cloudify Docker container is the most excelent image from Phussion team [https://github.com/phusion/baseimage-docker](https://github.com/phusion/baseimage-docker).

## Building container

Container builds in two phases:

 1. All Cloudify components (eg. Elasticsearch, RabbitMQ, Logstash, etc.)
 2. Cloudify Manager, REST,  service and other Stuff

> **Prerequisites** You need Docker and Internet access to be able to build
> Cloudify in Docker container.

### Components container

To build components container run:

	sh build-components-intermidiate-container.sh

in the **components-build** folder.

Once the build finishes, you can see **cfy_components** image build (run *docker images* from command line).

### Manager container

Once you got **Components container** build you can build Manager.

To build Manage Container run:

	sh build-manager.sh

in the **manager-build** folder.
Once the build is finished you should see **cfy_manager** added to list of images in docker.

> **IMPORTANT:**
> The manager container build will fail if the components container build was unsuccessful or not done at all.

### Running container

You can run container by running prepared script:

	sh run-manager-container.sh [optional-ip-address for Manager to use]

This script starts docker cfy_manager container with all services. It will also log in to bash in the running container so you can tail logs and look around as needed.

The script does TCP Port mapping between Docker Container and Docker Host. This makes Clodify manager available to the external world. 

> **IMPORTANT:**
> If you are running Docker inside VM (like I do via Vagrant) you might want to specify your HOST IP address as a parameter when starting Docker container, so Physical Host ports are mapped to VM ports, which in turn maps to Docker ports (yada-yada).
