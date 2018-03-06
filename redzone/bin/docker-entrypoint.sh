#!/bin/sh -eu

poll_zonefiles() {
  local timeout=${POLL_INTERVAL:-60}
  local reference=$(sha256sum "${CONFIG_FILE}")
  local comparison=''

  echo "Polling ${CONFIG_FILE} for changes"

  while true; do
    sleep ${timeout}
    test -z "${VERBOSE+x}" || echo "Probing for changes to ${CONFIG_FILE}"

    comparison=$(sha256sum "${CONFIG_FILE}")

    if test "${comparison}" != "${reference}"; then
      echo "Generating zones in ${ZONES_DIR} from ${CONFIG_FILE}"
      redzone generate "${ZONES_DIR}" --zones="${CONFIG_FILE}"
      reference="${comparison}"
    fi
  done
}

watch_zonefiles() {
  local watch_target=$(dirname "${CONFIG_FILE}")
  local watch_trigger=$(basename "${CONFIG_FILE}")

  echo "Watching ${CONFIG_FILE} for changes"

  inotifywait -e close_write,moved_to,create -m "${watch_target}" | \
  while read -r directory events filename; do
    test -z "${VERBOSE+x}" || echo "Change to ${filename} caused by ${events}"

    if test "${filename}" = "${watch_trigger}"; then
      echo "Generating zones in ${ZONES_DIR} from ${CONFIG_FILE}"
      redzone generate "${ZONES_DIR}" --zones="${CONFIG_FILE}"
    fi
  done
}

if test -z ${ZONES_DIR+x}; then
  ZONES_DIR=${1:-$PWD}
fi

if test -z ${CONFIG_FILE+x}; then
  CONFIG_FILE=${2:-/etc/redzone/zones.yml}
fi

case "${1:-generate-zonefiles}" in
  -*)
    exec redzone "$@"
    ;;
  generate-zonefiles)
    mkdir -p "${ZONES_DIR}"
    exec redzone generate "${ZONES_DIR}" --zones="${CONFIG_FILE}"
    ;;
  watch-zonefiles)
    mkdir -p "${ZONES_DIR}"
    watch_zonefiles
    ;;
  poll-zonefiles)
    mkdir -p "${ZONES_DIR}"
    poll_zonefiles
    ;;
  *)
    exec "$@"
    ;;
esac