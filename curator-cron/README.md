
[microbadger]: https://microbadger.com/images/uip9av6y/curator-cron
[docker library]: https://store.docker.com/images/python
[Apache]: https://github.com/elastic/curator/blob/master/LICENSE.txt
[vendor homepage]: https://www.elastic.co/guide/en/elasticsearch/client/curator/current/index.html
[cron expression format]: https://godoc.org/github.com/robfig/cron#hdr-CRON_Expression_Format
[curator action]: https://www.elastic.co/guide/en/elasticsearch/client/curator/current/actions.html

[![](https://images.microbadger.com/badges/image/uip9av6y/curator-cron.svg)][microbadger]
[![](https://images.microbadger.com/badges/version/uip9av6y/curator-cron.svg)][microbadger]
[![](https://images.microbadger.com/badges/commit/uip9av6y/curator-cron.svg)][microbadger]

# how to use this image

this image runs a cron daemon to execute curator based on
user defined rules.

all configuration is done via environment variables.

`docker run -d --name my-running-curator
  --env CURATOR_CRON_HOST=elastic.example.test
  --env CURATOR_CRON_SCHEDULE_EXAMPLE: "* * * * *|show_snapshots"
  curator-cron:latest`

the cron daemon is run as unprivileged user, so are the scheduled jobs.

the *examples/* directory contains a simple deployment setup
using docker-compose.

## environment variables

environment variables are the primary configuration source.

### general configuration

some variables affect all cron jobs.

* *CURATOR_CRON_CONFIG*

  curator parameter `--config`. added to all created jobs.

* *CURATOR_CRON_HOST*

  curator parameter `--host`. added to all created jobs.

* *CURATOR_CRON_URL_PREFIX*

  curator parameter `--url_prefix`. added to all created jobs.

* *CURATOR_CRON_PORT*

  curator parameter `--port`. added to all created jobs.

* *CURATOR_CRON_USE_SSL*

  curator parameter `--use_ssl`. added to all created jobs.

* *CURATOR_CRON_CERTIFICATE*

  curator parameter `--certificate`. added to all created jobs.

* *CURATOR_CRON_CLIENT_CERT*

  curator parameter `--client-cert`. added to all created jobs.

* *CURATOR_CRON_CLIENT_KEY*

  curator parameter `--client-key`. added to all created jobs.

* *CURATOR_CRON_SSL_NO_VALIDATE*

  curator parameter `--ssl-no-validate`. added to all created jobs.

* *CURATOR_CRON_HTTP_AUTH*

  curator parameter `--http_auth`. added to all created jobs.

* *CURATOR_CRON_TIMEOUT*

  curator parameter `--timeout`. added to all created jobs.

* *CURATOR_CRON_MASTER_ONLY*

  curator parameter `--master-only`. added to all created jobs.

* *CURATOR_CRON_DRY_RUN*

  curator parameter `--dry-run`. added to all created jobs.

* *CURATOR_CRON_LOGLEVEL*

  curator parameter `--loglevel`. added to all created jobs.

* *CURATOR_CRON_LOGFILE*

  curator parameter `--logfile`. added to all created jobs.

* *CURATOR_CRON_LOGFORMAT*

  curator parameter `--logformat`. added to all created jobs.

### curator jobs

the cronjob schedule is extracted from environment variables
starting with **CURATOR_CRON_SCHEDULE_**. the value of the
variables is a *|* (pipe character) delimited list of instructions:

* schedule

  [cron expression format][].

  default value: `* * * * *`

* curator action

  [curator action][].

  default value: *show_indices*

* curator action parameters.

  this value is forwarded to the executed job as-is.
  quotes must be escaped as they are lost otherwise during processing.

  default value: *--filter_list '{"filtertype":"none"}'*

# image setup

the image is based on the **python** image from
the [docker library][].

# license

the software contained in this image is licensed under the
[Apache][]. additional information can be found on the
[vendor homepage][].

as with all Docker images, these likely also contain other
software which may be under other licenses (such as Bash, etc
from the base distribution, along with any direct or indirect
dependencies of the primary software being contained).
it is the image user's responsibility to ensure that any use of
this image complies with any relevant licenses for all software
contained within.
