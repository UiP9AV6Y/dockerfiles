
[microbadger]: https://microbadger.com/images/uip9av6y/dns-blackhole
[docker library]: https://store.docker.com/images/python
[MIT]:  https://github.com/olivier-mauras/dns-blackhole/blob/master/LICENSE.txt
[vendor homepage]: https://github.com/olivier-mauras/dns-blackhole
[PowerDNS]: https://www.powerdns.com/
[Unbound]: http://unbound.net/
[Dnsmasq]: http://www.thekelleys.org.uk/dnsmasq/doc.html

[![](https://images.microbadger.com/badges/image/uip9av6y/dns-blackhole.svg)][microbadger]
[![](https://images.microbadger.com/badges/version/uip9av6y/dns-blackhole.svg)][microbadger]
[![](https://images.microbadger.com/badges/commit/uip9av6y/dns-blackhole.svg)][microbadger]

# how to use this image

this image is intended to be used as sidekick for DNS resolvers
such as PowerDNS, Dnsmasq or Unbound. it can be configured with
environment variables as well as commandline switches.

`docker run -d --name my-running-dns-blackhole
  -v /etc/dnsmasq.d/:/data
  -e "DNSBH_HOSTS_mvps=http://winhelp2002.mvps.org/hosts.txt"
  dns-blackhole:latest
  -s dnsmasq -o /data/blocked.conf`

the *examples/* directory contains a suggested deployment setup
using docker-compose.

## environment variables

* *DNSBH_BLACKLIST*

  file to store blacklist domains in.
  default: /etc/dns-blackhole/blacklist
* *DNSBH_WHITELIST*

  file to store whitelist domains in.
  default: /etc/dns-blackhole/whitelist
* *DNSBH_CONFIG*

  dns-blackhole configuration file.
  default: /etc/dns-blackhole/dns-blackhole.yml

* *DNSBH_FILE*

  file where dns-blackhole writes the processed data to.

* *DNSBH_DATA*

  string template to used for formatting.
  (e.g. *block={domain}*)

* *DNSBH_DISCONNECT_URL*

  URL for the **disconnect.me** blocklist.

* *DNSBH_DISCONNECT_CATEGORIES*

  space separated list of categories to use from
  the **disconnect.me** blocklist.

* *DNSBH_HOSTS_*

  all environment variables with this prefix are expected
  to contain blocklist URLs.
  (e.g. *DNSBH_HOSTS_mvps*=**http://winhelp2002.mvps.org/hosts.txt**)

* *DNSBH_EASYLIST_*

  all environment variables with this prefix are expected
  to contain easylist filter rule URLs.

## commandline switches

* `-o FILE`

  output file to generate with dns-blackhole
  (see *DNSBH_FILE*)
* `-f FORMAT`

  output format to render host entries
  (see *DNSBH_DATA*)
* `-s SYSTEM`

  render host entries compatible with the given system.
  this is an alias for `-f` and currently supports
  the following values:

  * **unbound**

  format compatible with [Unbound][]
  * **unbound-server**

  similar to **unbound**, except that each entry is parented
  to a *server* configuration node.
  * **powerdns**

  format compatible with [PowerDNS][]
  * **dnsmasq**

  format compatible with [Dnsmasq][]


environment variable overwrite values provided via
commandline arguments.

# image setup

the image is based on the **3-alpine** tagged **python** image
from the [docker library][].

# license

the software contained in this image is licensed under the
[MIT][]. additional information can be found on the
[vendor homepage][].

as with all Docker images, these likely also contain other
software which may be under other licenses (such as Bash, etc
from the base distribution, along with any direct or indirect
dependencies of the primary software being contained).
it is the image user's responsibility to ensure that any use of
this image complies with any relevant licenses for all software
contained within.