
[microbadger]: https://microbadger.com/images/uip9av6y/unifi-controller
[docker library]: https://store.docker.com/images/openjdk
[GPL-3.0]: http://www.gnu.org/licenses/gpl-3.0.txt
[vendor homepage]: https://www.ubnt.com/download/unifi/default/default/unifi-5629-controller-debianubuntu-linux
[official documentation]: https://help.ubnt.com/hc/en-us/articles/205202580-UniFi-system-properties-File-Explanation

[![](https://images.microbadger.com/badges/image/uip9av6y/unifi-controller.svg)][microbadger]
[![](https://images.microbadger.com/badges/version/uip9av6y/unifi-controller.svg)][microbadger]
[![](https://images.microbadger.com/badges/commit/uip9av6y/unifi-controller.svg)][microbadger]

# how to use this image

this image is intended to be used in combination with an
external/linked mongodb instance. as such, it is not operational
on its own. apart from that, it ships with default settings
suitable for the average deployment.

the *examples/* directory contains a suggested deployment setup
using docker-compose.

## using a customized image

```dockerfile
FROM unifi-controller:latest
COPY system.properties /usr/lib/unifi/data/
```

build the container either manually ( `docker build -t my-unifi-controller .`) or via build system (`make build`)

if the customized image does **not** spawn a mongodb server,
you must link it to the container or make it otherwise accessible.

`docker run -d --name my-running-unifi-controller
  --add-host=mongo:10.180.0.1
  my-unifi-controller`

you may need to publish the ports your unifi-controller is
listening on to the host by specifying the -p option, for example
*-p 80:8080* to publish port 80 from the container host to port
8080 in the container. make sure the port you're using is free.

## using environment variables

`docker run -d --name my-running-unifi-controller
  --env SYSTEM_IP=10.24.0.1
  --link some-mongo:mongo
  unifi-controller:latest`

* *SYSTEM_IP*

  public address for communication with devices

* *DATADIR*

  storage directory for configuration.

  default: /usr/lib/unifi/data

* *LOGDIR*

  storage directory for log files

  default: /usr/lib/unifi/logs

* *RUNDIR*

  storage directory for runtime files

  default: /usr/lib/unifi/run

* *DB_NAME*

  database name and name prefix for the stats db

  default: unifi-ace

* *MONGO_HOST*

  host name/address of the mongo db instance

  default: **$MONGO_PORT_27017_TCP_ADDR** or mongo

* *MONGO_PORT*

  port number of the mongo db instance

  default: **$MONGO_PORT_27017_TCP_PORT** or 27017

## with custom instructions via commandline

`docker run -d --name my-running-unifi-controller
  --link some-mongo:mongo
  unifi-controller:latest
  unifi -i 10.24.0.1`

to get more information about the supported commandlines,
run the image with the *-h* option

`docker run --rm -it unifi-controller:latest unifi -h`

## directly via bind mount

`docker run -d --name my-running-unifi-controller
  -v /path/to/unifi/data:/usr/lib/unifi/data:ro
  unifi-controller:latest`

note that your host's `/path/to/unifi/data` folder should be
populated with a file named `system.properties`. for more
information about its content refer to the
[official documentation][].

# image setup

the image is based on the **8-jre** tagged **openjdk** image from
the [docker library][].

# license

the software contained in this image is licensed under the
[GPL-3.0][]. additional information can be found on the
[vendor homepage][].

as with all Docker images, these likely also contain other
software which may be under other licenses (such as Bash, etc
from the base distribution, along with any direct or indirect
dependencies of the primary software being contained).
it is the image user's responsibility to ensure that any use of
this image complies with any relevant licenses for all software
contained within.