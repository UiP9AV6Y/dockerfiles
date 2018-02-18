#!/bin/sh
set -eu

setup_backend() {
  local pdns_conf="${PDNS_HOME}/pdns.conf"
  local mysql_conf="${HOME}/.my.cnf"
  local mysql_host="${DB_HOST:-powerdns}"
  local mysql_port="${DB_PORT:-3306}"
  local mysql_user=${DB_USER:-powerdns}
  local mysql_password=${DB_PASS:-powerdns}
  local mysql_database=${DB_NAME:-pdns}
  local mysql_timeout=${MYSQL_TIMEOUT:-10}
  local config_start_marker='# backend'
  local config_end_marker='# eo backend'
  local connection_attempts=0

  cat <<EOF > "${mysql_conf}"
[mysql]
user=${mysql_user}
password=${mysql_password}
database=${mysql_database}
connect_timeout=${mysql_timeout}
EOF

  sed -i -e "/${config_start_marker}/,/${config_end_marker}/d" "${pdns_conf}"
  cat <<EOF >> "${pdns_conf}"
${config_start_marker}
launch=gmysql
gmysql-user=${mysql_user}
gmysql-password=${mysql_password}
gmysql-dbname=${mysql_database}
gmysql-timeout=${mysql_timeout}
EOF

  if test -n "${PDNS_DNSSEC+x}"; then
    echo 'gmysql-dnssec=yes' >> "${pdns_conf}"
  fi

  if test -n "${MYSQL_SOCKET+x}" -o "${mysql_host}" = 'localhost'; then
    cat <<EOF >> "${mysql_conf}"
protocol=SOCKET
host=localhost
socket=${DB_SOCKET:-/var/run/mysqld/mysqld.sock}
EOF
    cat <<EOF >> "${pdns_conf}"
gmysql-socket=${DB_SOCKET:-/var/run/mysqld/mysqld.sock}
EOF
  else
    cat <<EOF >> "${mysql_conf}"
protocol=TCP
host=${mysql_host}
port=${mysql_port}
EOF
    cat <<EOF >> "${pdns_conf}"
gmysql-host=${mysql_host}
gmysql-port=${mysql_port}
EOF
  fi

  echo "${config_end_marker}" >> "${pdns_conf}"

  while ! mysql -r -s -B -e 'SHOW TABLES' >/dev/null 2>&1; do
    if test "${connection_attempts}" -ge 15; then
      echo "unable to connect to backend ${mysql_host}" 1>&2
      exit 1
    fi

    echo "waiting for connection to backend ${mysql_host}"
    sleep ${connection_attempts}
    connection_attempts=$(expr "${connection_attempts}" + 1)
  done

  if mysql -r -s -B -e 'SELECT 1 FROM domains' >/dev/null 2>&1; then
    echo "backend ${mysql_host} already provisioned"
  else
    echo "provisioning backend ${mysql_host}"
    mysql -r -s -B < /usr/share/doc/pdns/schema.mysql.sql
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