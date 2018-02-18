#!/bin/sh
set -eu

setup_backend() {
  local pdns_conf="${PDNS_HOME}/pdns.conf"
  local pgsql_host="${DB_HOST:-powerdns}"
  local pgsql_port="${DB_PORT:-5432}"
  local pgsql_user=${DB_USER:-powerdns}
  local pgsql_password=${DB_PASS:-powerdns}
  local pgsql_database=${DB_NAME:-pdns}
  local config_start_marker='# backend'
  local config_end_marker='# eo backend'
  local connection_attempts=0

  export PGPASSWORD="${pgsql_password}"
  export PGDATABASE="${pgsql_database}"
  export PGUSER="${pgsql_user}"
  export PGHOST="${pgsql_host}"
  export PGPORT="${pgsql_port}"

  sed -i -e "/${config_start_marker}/,/${config_end_marker}/d" "${pdns_conf}"
  cat <<EOF >> "${pdns_conf}"
${config_start_marker}
launch=gpgsql
gpgsql-user=${pgsql_user}
gpgsql-host=${pgsql_host}
gpgsql-port=${pgsql_port}
gpgsql-password=${pgsql_password}
gpgsql-dbname=${pgsql_database}
EOF

  if test -n "${PDNS_DNSSEC+x}"; then
    echo 'gpgsql-dnssec=yes' >> "${pdns_conf}"
  fi

  if test -n "${PGSQL_PARAMETERS+x}"; then
    echo "gpgsql-extra-connection-parameter=${DB_PARAMETERS}" >> "${pdns_conf}"
  fi

  echo "${config_end_marker}" >> "${pdns_conf}"

  while ! psql -w -l >/dev/null 2>&1; do
    if test "${connection_attempts}" -ge 15; then
      echo "unable to connect to backend ${pgsql_host}" 1>&2
      exit 1
    fi

    echo "waiting for connection to backend ${pgsql_host}"
    sleep ${connection_attempts}
    connection_attempts=$(expr "${connection_attempts}" + 1)
  done

  if psql -w -c 'SELECT 1 FROM domains' >/dev/null 2>&1; then
    echo "backend ${pgsql_host} already provisioned"
  else
    echo "provisioning backend ${pgsql_host}"
    psql -w < /usr/share/doc/pdns/schema.pgsql.sql
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