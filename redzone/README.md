
[microbadger]: https://microbadger.com/images/uip9av6y/redzone
[docker library]: https://store.docker.com/images/ruby
[MIT]: https://github.com/justenwalker/redzone/blob/master/LICENSE.md
[RedZone]: https://github.com/justenwalker/redzone
[upstream example]: https://github.com/justenwalker/redzone/blob/master/zones.yml.example

[![](https://images.microbadger.com/badges/image/uip9av6y/redzone.svg)][microbadger]
[![](https://images.microbadger.com/badges/version/uip9av6y/redzone.svg)][microbadger]
[![](https://images.microbadger.com/badges/commit/uip9av6y/redzone.svg)][microbadger]

# RedZone

[RedZone][] is a command-line too that can generate bind zone files and configuration from yaml syntax.

this docker image acts as a simple wrapper around the core
logic of redzone.

# how to use this image

internally the default command of this image calls
`redzone generate`. the output directory as well as the
input configuration can be configured either via commandline
arguments or environment variables.

## with instructions via enviroment variables

| Variable | Description | Type | Default value |
| -------- | ----------- | ---- | ------------- |
| **ZONES_DIR** | output directory | directory | *$PWD* |
| **CONFIG_FILE** | zone configuration | file | /etc/redzone/zones.yml |

## with instructions via commandline

`docker run --rm -it --name my-redzone
  redzone:latest
  /var/named /etc/redzone/zones.yml`

the first positional argument specifies the directory where
converted zone files are placed. prior to conversion, this
directory is created should it not exist already. the default
value is the working directory of the container.
(see **ZONES_DIR**)

the seconds argument is optional as well and specifies the
YAML file containing zone information to be converted.
for more information about the format, consult the [upstream
example][].
(see **CONFIG_FILE**)

# image setup

the image is based on the **ruby:alpine** image from
the [docker library][].

# license

the software contained in this image is licensed under the
[MIT][]. additional information can be found on the
[vendor homepage][RedZone].

as with all Docker images, these likely also contain other
software which may be under other licenses (such as Bash, etc
from the base distribution, along with any direct or indirect
dependencies of the primary software being contained).
it is the image user's responsibility to ensure that any use of
this image complies with any relevant licenses for all software
contained within.