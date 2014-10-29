Cloudify CLI container
=======================


		Cloudify CLI container. Build to work with prepared manager that runs REST Api on different port (8180).


### Building container

To build container run **build-cli-container.sh**.


### Using container

Start container by running **run-cli-container.sh**. You should get running container with Cloudify CLI in it.


		Check by running **cfy -h**


By default Host folder **/path/to/cloned/repo/cli/blueprints** is mapped to **/blueprints** in the Docker CLI container.

You can put your blueprints in there from your host and available in guest!