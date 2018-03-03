#!/bin/sh -eu

if test -z ${ZONES_DIR+x}; then
  ZONES_DIR=${1:-$PWD}
fi

if test -z ${CONFIG_FILE+x}; then
  CONFIG_FILE=${2:-/etc/redzone/zones.yml}
fi

mkdir -p "${ZONES_DIR}"

exec redzone generate "${ZONES_DIR}" --zones="${CONFIG_FILE}"