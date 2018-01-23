
[microbadger]: https://microbadger.com/images/uip9av6y/compose-scheduler
[docker hub]: https://hub.docker.com/r/docker/compose/
[Apache-2.0]: https://www.apache.org/licenses/LICENSE-2.0
[project homepage]: https://github.com/docker/compose
[environment variables]: https://docs.docker.com/compose/reference/envvars/

[![](https://images.microbadger.com/badges/image/uip9av6y/compose-scheduler.svg)][microbadger]
[![](https://images.microbadger.com/badges/version/uip9av6y/compose-scheduler.svg)][microbadger]
[![](https://images.microbadger.com/badges/commit/uip9av6y/compose-scheduler.svg)][microbadger]

# how to use this image

this image is intended to be used with docker-compose
for automated/reocurring orchestration. it is quite useless on its
own and requires other docker-compose services for management.

under the hood, this image uses *crond* to schedule interactions
with docker-compose services. all [environment variables] defined
for the docker container are available to the compose binary.

the *examples/* directory contains a suggested deployment setup
using docker-compose.

## using a customized image

```dockerfile
FROM compose-scheduler:latest
ENV SCHEDULE_service_1="service-1 start @daily"
WORKDIR /myproject
COPY ./docker-compose.yml /myproject
```

build the container either manually ( `docker build -t my-compose-scheduler .`) or via build system (`make build`)

the customized image still required access to the docker socket,
which must be mounted upon launch.

`docker run -d --name my-running-compose-scheduler
  -v /var/run/docker.sock:/var/run/docker.sock
  my-compose-scheduler`

## with custom instructions via commandline

`docker run -d my-running-compose-scheduler
  -v /var/run/docker.sock:/var/run/docker.sock
  compose-scheduler:latest
  -l 1`

to get more information about the supported commandlines,
run the image with the *-h* option

`docker run --rm -it compose-scheduler:latest -h`

# image setup

the image is based on the latest version number tagged
**compose** image from the [docker hub][].

# license

the software contained in this image is licensed under the
[Apache-2.0][]. additional information can be found on the
[project homepage][].

as with all Docker images, these likely also contain other
software which may be under other licenses (such as Bash, etc
from the base distribution, along with any direct or indirect
dependencies of the primary software being contained).
it is the image user's responsibility to ensure that any use of
this image complies with any relevant licenses for all software
contained within.