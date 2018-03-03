
[microbadger]: https://microbadger.com/images/uip9av6y/nsd
[docker library]: https://store.docker.com/images/alpine
[BSD]: https://www.nlnetlabs.nl/svn/nsd/trunk/LICENSE
[vendor homepage]: https://www.nlnetlabs.nl/projects/nsd/

[![](https://images.microbadger.com/badges/image/uip9av6y/nsd.svg)][microbadger]
[![](https://images.microbadger.com/badges/version/uip9av6y/nsd.svg)][microbadger]
[![](https://images.microbadger.com/badges/commit/uip9av6y/nsd.svg)][microbadger]

# how to use this image

this image provides NSD, an authoritative only, high
performance, simple and open source name server.

the configuration is slightly opiniated and the majority of
input has to be provided during deployment; the image exposes
the respective volumes to do so.

`docker run -d --name my-running-nsd
  --mount type=bind,source=$PWD/config,destination=/etc/nsd/conf.d
  --mount type=bind,source=$PWD/zones,destination=/etc/nsd/zones.d
  --env ACCESS_KEY_transfer: 'transfer hmac-sha256 6KM6qiKfwfEpamEq72HQdA=='
  nsd:latest`

the directory **$PWD/config** must exist on the host and is
expected to contain nsd configuration (e.g. zones) . its
content is included in the toplevel hierarchy of the nsd main
config.
server related settings can be mounted into
**/etc/nsd/server-conf.d**, as its content is included under
the toplevel *server* key. (only a single *server* can exist)

the working directory of NSD is **/etc/nsd**. paths can be
specified either relative to this location or using absolute
values.

```yaml
zone:
  name: my-zone-net
  zonefile: zones.d/my-zone.net.db

zone:
  name: my-zone-com
  zonefile: /etc/nsd/zones.d/my-zone.com.db
```

the *examples/* directory contains a simple deployment setup
using docker-compose.

## environment variables

* *DISABLE_CONTROL_SETUP*

  defining this environment variable will prevent the SSL keys and
  certificates for `nsd-control` from being created. those files reside in
  */etc/nsd/ssl* and are used by the container healthcheck.
* *LAZY_CONTROL_SETUP*

  in combination with *DISABLE_CONTROL_SETUP*, this environment variable
  controls the behaviour, should the certificates already exist. if the
  variable is defined, the certificates will only be generated if not already
  present, otherwise they will be created with every container start.
* *SERVER_COUNT*

  number of threads to fork. the default is equal to the number of CPUs.
* *DISABLE_REUSEPORT*

  disable the use of the *SO_REUSEPORT* socket option, otherwise NSD will
  create file descriptors for every server in the server-count.  this
  improves performance of the network stack. only really useful if you also
  configure a server-count higher than 1
* *ACCESS_KEY_*

  Environment variables with this name prefix are parsed for communication
  keys. The format is a space separated list of the following parts

  1. name
  2. algorithm
  3. base64 encoded secret

  example: **transfer hmac-sha256 6KM6qiKfwfEpamEq72HQdA==**

# image setup

the image is based on the **alpine** image from
the [docker library][].

# license

the software contained in this image is licensed under the
[BSD][]. additional information can be found on the
[vendor homepage][].

as with all Docker images, these likely also contain other
software which may be under other licenses (such as Bash, etc
from the base distribution, along with any direct or indirect
dependencies of the primary software being contained).
it is the image user's responsibility to ensure that any use of
this image complies with any relevant licenses for all software
contained within.