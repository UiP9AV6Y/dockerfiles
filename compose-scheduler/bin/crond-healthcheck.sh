#!/bin/sh -eu

CRON_HEALTH=/var/run/cron.lastrun
CRON_MTIME=$(date -r "$CRON_HEALTH" -u '+%s')
NOW=$(date -u '+%s')
# the keepalive job runs every minute. we add a (generous) buffer
# to compensate for time drift and scheduling deltas
CRIT=$(expr $NOW - 70)

if test ${CRON_MTIME} -gt ${CRIT}; then
  printf "OK: crond is up and running. last contact: "
  date -r "${CRON_HEALTH}"
  exit 0
else
  printf "CRITICAL: crond seems to be unresponsive. last contact: "
  date -r "${CRON_HEALTH}"
  exit 1
fi