#!/bin/sh -eu
set -eu -o noglob

: "${CURATOR_CRON_D:=/etc/cron.d}"
: "${CURATOR_EXECUTABLE:=/usr/local/bin/curator_cli}"

CURATOR_CRON_USER="$(id -un)"

shared_curator_args() {
  local args

  args=''

  if test -n "${CURATOR_CRON_CONFIG+x}"; then
    args="${args} --config ${CURATOR_CRON_CONFIG}"
  fi
  if test -n "${CURATOR_CRON_HOST+x}"; then
    args="${args} --host ${CURATOR_CRON_HOST}"
  fi
  if test -n "${CURATOR_CRON_URL_PREFIX+x}"; then
    args="${args} --url_prefix ${CURATOR_CRON_URL_PREFIX}"
  fi
  if test -n "${CURATOR_CRON_PORT+x}"; then
    args="${args} --port ${CURATOR_CRON_PORT}"
  fi
  if test -n "${CURATOR_CRON_USE_SSL+x}"; then
    args="${args} --use_ssl"
  fi
  if test -n "${CURATOR_CRON_CERTIFICATE+x}"; then
    args="${args} --certificate ${CURATOR_CRON_CERTIFICATE}"
  fi
  if test -n "${CURATOR_CRON_CLIENT_CERT+x}"; then
    args="${args} --client-cert ${CURATOR_CRON_CLIENT_CERT}"
  fi
  if test -n "${CURATOR_CRON_CLIENT_KEY+x}"; then
    args="${args} --client-key ${CURATOR_CRON_CLIENT_KEY}"
  fi
  if test -n "${CURATOR_CRON_SSL_NO_VALIDATE+x}"; then
    args="${args} --ssl-no-validate ${CURATOR_CRON_SSL_NO_VALIDATE}"
  fi
  if test -n "${CURATOR_CRON_HTTP_AUTH+x}"; then
    args="${args} --http_auth ${CURATOR_CRON_HTTP_AUTH}"
  fi
  if test -n "${CURATOR_CRON_TIMEOUT+x}"; then
    args="${args} --timeout ${CURATOR_CRON_TIMEOUT}"
  fi
  if test -n "${CURATOR_CRON_MASTER_ONLY+x}"; then
    args="${args} --master-only"
  fi
  if test -n "${CURATOR_CRON_DRY_RUN+x}"; then
    args="${args} --dry-run"
  fi
  if test -n "${CURATOR_CRON_LOGLEVEL+x}"; then
    args="${args} --loglevel ${CURATOR_CRON_LOGLEVEL}"
  fi
  if test -n "${CURATOR_CRON_LOGFILE+x}"; then
    args="${args} --logfile ${CURATOR_CRON_LOGFILE}"
  fi
  if test -n "${CURATOR_CRON_LOGFORMAT+x}"; then
    args="${args} --logformat ${CURATOR_CRON_LOGFORMAT}"
  fi

  echo "${args}"
}

crontab() {
  local cmd
  local job
  local user
  local comment
  local options
  local schedule
  local action
  local args

  job="$1"
  comment="$2"
  user="$3"
  cmd="$4"
  shift 4
  options="$@"

  set -f; IFS='|'
  set -- $job
  schedule=${1:-* * * * *}
  action=${2:-show_indices}
  args=${3:-}
  set +f; unset IFS

  if test -z "$args"; then
    args="--filter_list '{\"filtertype\":\"none\"}'"
  fi

  echo "# ${comment}"
  echo "$schedule $user $cmd $options $action $args"
}

curator_jobs() {
  local comment
  local value

  printf '# creation date %s\n\n' "$(date -Iseconds)"

  env | grep CURATOR_CRON_SCHEDULE_ | while read schedule; do
    comment=${schedule%%=*}
    value="${schedule#*=}"
    crontab "$value" "$comment" "$CURATOR_CRON_USER" "${CURATOR_EXECUTABLE}" "$@"
  done
}

if test $# -gt 0; then
  case "$1" in
    -*)
      # some option argument
      break
      ;;
    crond)
      # remove argument as we prepend it later anyway
      shift
      ;;
    *)
      # command, unrelated to the purpose of this image
      exec "$@"
      ;;
  esac
fi

curator_jobs $(shared_curator_args) > "${CURATOR_CRON_D}/${CURATOR_CRON_USER}"

exec crond --default-user "${CURATOR_CRON_USER}" "$@"
