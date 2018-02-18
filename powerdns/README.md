
[microbadger]: https://microbadger.com/images/uip9av6y/powerdns
[docker library]: https://store.docker.com/images/alpine
[GPL-2.0]: https://github.com/PowerDNS/pdns/blob/master/COPYING
[vendor homepage]: https://powerdns.com/
[connection timeout]: https://docs.powerdns.com/authoritative/backends/generic-mysql.html#gmysql-timeout
[extra parameters]: https://docs.powerdns.com/authoritative/backends/generic-postgresql.html#gpsql-extra-connection-parameters
[synchronous]: https://docs.powerdns.com/authoritative/backends/generic-sqlite3.html#gsqlite3-pragma-synchronous
[foreign key]: https://docs.powerdns.com/authoritative/backends/generic-sqlite3.html#gsqlite3-pragma-foreign-keys
[supported values]: https://sqlite.org/pragma.html#pragma_synchronous

[![](https://images.microbadger.com/badges/image/uip9av6y/powerdns.svg)][microbadger]
[![](https://images.microbadger.com/badges/version/uip9av6y/powerdns.svg)][microbadger]
[![](https://images.microbadger.com/badges/commit/uip9av6y/powerdns.svg)][microbadger]

# how to use this image

this image contains the PowerDNS Authoritative Server.
each tagged version contains a single backend support.
currently supported backends/tags:

* mysql
* postgres (tagged as pgsql)
* sqlite3

`docker run -d --name my-running-powerdns
  --mount type=volume,target=/data
  --env ENABLE_CATCH_ALL=yes
  powerdns:sqlite3 --gsqlite3-pragma-foreign-keys=yes`

the image comes with a minimalistic configuration.
fine-tuning and performance optimizations are left
to the user. the configuration volume (*/etc/pdns/conf.d*)
can be used for that purpose.

apart from the DNS ports (53/tcp 53/udp) a control interface
is also exposed. it can be accessed either via TCP (port *53000*), or via socket (the respective volume */var/run/pdns* is exposed).

additionally the webserver interface, exposing statistics, is
also available on port 8081.

the database scheme is created automatically upon first
start. schema migrations are a task left to the user.

the *examples/* directory contains a simple deployment setup
using docker-compose.

## environment variables

the PowerDNS server can be controlled entirely via
commandline arguments. this image also supports environment
variables as configuration source for selected settings.

* *DB_HOST* (mysql, pgsql, sqlite3)

  database hostname. for the *sqlite3* image, this is the
  path to the database file (presumably mounted as volume)

  default: powerdns (mysql, pgsql), /data/powerdns.sqlite3 (sqlite3)

* *DB_PORT* (mysql, pgsql)

  database port.

  default: 3306 (mysql), 5432 (pgsql)

* *DB_NAME* (mysql, pgsql)

  database name.

  default: pdns

* *DB_USER* (mysql, pgsql)

  database authentication identifier.

  default: powerdns

* *DB_PASS* (mysql, pgsql)

  database authentication secret.

  default: powerdns

* *PDNS_DNSSEC* (mysql, pgsql, sqlite3)

  if defined DNSSEC processing is enabled.

* *MYSQL_TIMEOUT* (mysql)

  read/write attempt [connection timeout][]

  default: 10

* *PGSQL_PARAMETERS* (pgsql)

  [extra parameters][] forwarded to postgres.

* *SQLITE3_SYNCHRONOUS* (sqlite3)

  if defined, controls the [synchronous][] flag.

  [supported values][] include: 0 (OFF), 1 (NORMAL), 2 (FULL), 3 (EXTRA)

* *SQLITE3_FOREIGN_KEYS* (sqlite3)

  if defined, enables [foreign key] constraints

# image setup

the image is based on the **alpine** image from
the [docker library][].

# license

the software contained in this image is licensed under the
[GPL-2.0][]. additional information can be found on the
[vendor homepage][].

as with all Docker images, these likely also contain other
software which may be under other licenses (such as Bash, etc
from the base distribution, along with any direct or indirect
dependencies of the primary software being contained).
it is the image user's responsibility to ensure that any use of
this image complies with any relevant licenses for all software
contained within.