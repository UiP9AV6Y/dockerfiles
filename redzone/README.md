
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

## auto-compiling zones

the default behaviour of the image is to act as a one-off
command, compiling zone data on startup. the image also
supports continuous compilation by either polling the
input configuration for changes or reacting to changes
to the file via kernel events.

### `watch-zonefiles`

internally the image uses `inotifywait` to listen for
changes to the zone configuration file. this requires
those events to be actually emitted inside of a
docker container, which dependend on the host OS and
docker volume plugin in use, might not be the case.

additional environment variables are supported for this
workflow

| Variable | Description | Type | Default value |
| -------- | ----------- | ---- | ------------- |
| **VERBOSE** | log *all* inotify events in the config file directory | any | none |

### `poll-zonefiles`

an infinite loop will inspect the configuration file for
changes and trigger a zone compilation.
while the `watch-zonefiles` workflow will trigger on any
modification event, `poll-zonefiles` will only act if the
configuration file has actually changed in content (it
compares the checksums internally)

| Variable | Description | Type | Default value |
| -------- | ----------- | ---- | ------------- |
| **VERBOSE** | log when a scan is performed | any | none |
| **POLL_INTERVAL** | time in seconds to wait between scans | integer | 60 |

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