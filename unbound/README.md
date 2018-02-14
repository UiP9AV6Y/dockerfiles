
[microbadger]: https://microbadger.com/images/uip9av6y/unbound
[docker library]: https://store.docker.com/images/alpine
[BSD]: http://unbound.nlnetlabs.nl/svn/trunk/LICENSE
[vendor homepage]: http://unbound.net/
[optimization]: https://unbound.net/documentation/howto_optimise.html
[NSD]: https://www.nlnetlabs.nl/projects/nsd/
[Bind]: https://www.isc.org/downloads/bind/
[PowerDNS]: https://www.powerdns.com/

[![](https://images.microbadger.com/badges/image/uip9av6y/unbound.svg)][microbadger]
[![](https://images.microbadger.com/badges/version/uip9av6y/unbound.svg)][microbadger]
[![](https://images.microbadger.com/badges/commit/uip9av6y/unbound.svg)][microbadger]

# how to use this image

this image provides Unbound, a validating, recursive, and
caching DNS resolver. it is intended to be deployed either
as standalone instance or alongside an authoritative
DNS server such as [Bind][], [PowerDNS][] or [NSD][].

the configuration is slightly opiniated and the majority of
input has to be provided during deployment; the image exposes
the respective volumes to do so.

`docker run -d --name my-running-unbound
  --mount type=bind,source=$PWD/config,destination=/etc/unbound/conf.d
  --env ENABLE_CATCH_ALL=yes
  unbound:latest`

the directory **$PWD/config** must exist on the host and is
expected to contain unbound configuration. its content is
included in the toplevel hierarchy of the unbound main config.
(i.e.: server related settings must be parented under a
*server* section)

if the opiniated settings are not to your liking, you can
either mount an empty directory over
**/etc/unbound/server-conf.d**, or provide your own main
configuration file (**/etc/unbound/unbound.conf**)

the *examples/* directory contains a simple deployment setup
using docker-compose.

## environment variables

environment variables can be used to control the behaviour of
some commonly tweaked settings without the need to mount a
configuration volume.

### catch-all forwarder

if the environment variable *ENABLE_CATCH_ALL* is defined,
a forward zone for all unhandled queries is created. without
further instructions, the nameservers **8.8.8.8** and
**8.8.4.4** are used. *UPSTREAM_PRIMARY* can be used to change
the first server, *UPSTREAM_SECONDARY* to change the second.

### preconfigured optimization

defining the environment variable *ENABLE_OPTIMIZATION* will
result in additional configuration settings with [optimization][]
values for large scale deployments.

some values can be changed with further variables:

* *MSG_CACHE_SIZE*

  defines the *msg-cache-size* value in megabytes. the
  *rrset-cache-size* value is calculated based on this values
  and is twice the size. the default values are 50m (and 100m respective)

* *CACHE_SLABS*

  size values for the following unbound settings:

  *msg-cache-slabs*, *rrset-cache-slabs*,
  *infra-cache-slabs*, *key-cache-slabs*

  the default values are the number of processors available to the
  docker container.

* *SO_RCVBUF*

  size in megabytes for the receive buffer *so-rcvbuf*

  the default value is 4m

* *SO_SNDBUF*

  size in megabytes for the send buffer *so-sndbuf*

  the default value is 4m

### auxiliary files

root zone hints, trust anchors and control SSL certificates,
are created automatically upon startup unless disabled:

* *DISABLE_CABUNDLE_CREATION*

  the existence of this environment variable prevents the
  creation of the ICANN root update certificate file
  /etc/unbound/aux/icannbundle.pem

* *DISABLE_HINTS_CREATION*

  if set, the root hints file (/etc/unbound/aux/root.hints)
  will not be created/updated

* *DISABLE_ANCHOR_CREATION*

  if set, the DNS root zone anchors (/etc/unbound/aux/root.key)
  will not be created/updated

* *DISABLE_CONTROL_SETUP*

  defining this environment variable will prevent the SSL
  keys and certificates for `unbound-control` from being created.
  those files reside in /etc/unbound/ssl and are used by the
  container healthcheck.

* *LAZY_CONTROL_SETUP*

  in combination with *DISABLE_CONTROL_SETUP*, this environment
  variable controls the behaviour, should the certificates
  already exist. if the variable is defined, the certificates
  will only be generated if not already present, otherwise they
  will be created with every container start.

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