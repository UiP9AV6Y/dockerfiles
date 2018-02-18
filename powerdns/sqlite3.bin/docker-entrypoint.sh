#!/bin/sh
set -eu

setup_backend() {
  local pdns_conf="${PDNS_HOME}/pdns.conf"
  local sqlite3_host="${DB_HOST:-/data/powerdns.sqlite3}"
  local config_start_marker='# backend'
  local config_end_marker='# eo backend'

  sed -i -e "/${config_start_marker}/,/${config_end_marker}/d" "${pdns_conf}"
  cat <<EOF >> "${pdns_conf}"
${config_start_marker}
launch=gsqlite3
gsqlite3-database=${sqlite3_host}
EOF

  if test -n "${PDNS_DNSSEC+x}"; then
    echo 'gsqlite3-dnssec=yes' >> "${pdns_conf}"
  fi

  if test -n "${SQLITE3_SYNCHRONOUS+x}"; then
    echo "gsqlite3-pragma-synchronous=${SQLITE3_SYNCHRONOUS}" >> "${pdns_conf}"
  fi

  if test -n "${SQLITE3_FOREIGN_KEYS+x}"; then
    echo 'gsqlite3-pragma-foreign-keys=yes' >> "${pdns_conf}"
  fi

  echo "${config_end_marker}" >> "${pdns_conf}"

  if sqlite3 "${sqlite3_host}" 'SELECT 1 FROM domains' >/dev/null 2>&1; then
    echo "backend ${sqlite3_host} already provisioned"
  else
    echo "provisioning backend ${sqlite3_host}"
    sqlite3 "${sqlite3_host}" < /usr/share/doc/pdns/schema.sqlite3.sql
  fi
}

if test $# -gt 0; then
  case "$1" in
    -*)
      # some option argument
      break
      ;;
    pdns|pdns_server)
      # remove argument as we prepend it later anyway
      shift
      ;;
    *)
      # command, unrelated to the purpose of this image
      exec "$@"
      ;;
  esac
fi

setup_backend

exec pdns_server --daemon=no "$@"