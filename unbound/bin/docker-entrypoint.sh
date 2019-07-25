#!/bin/sh
set -eu -o noglob

GLOBAL_INCLUDE_D=${UNBOUND_HOME}/include.d/global
SERVER_INCLUDE_D=${UNBOUND_HOME}/include.d/server
REMOTE_INCLUDE_D=${UNBOUND_HOME}/include.d/remote

catch_all_forwarder() {
  cat <<EOF
forward-zone:
    name: "."
    forward-addr: ${UPSTREAM_PRIMARY:-8.8.8.8}
    forward-addr: ${UPSTREAM_SECONDARY:-8.8.4.4}
EOF
}

server_optimization() {
  NUMPROC=$(nproc)
  MSG_SIZE=${MSG_CACHE_SIZE:-50}
  RRSET_SIZE=$(expr ${MSG_SIZE} * 2)
  SLABS=${CACHE_SLABS:-${NUMPROC}}

  cat <<EOF
num-threads: ${NUMPROC}

msg-cache-slabs: ${SLABS}
rrset-cache-slabs: ${SLABS}
infra-cache-slabs: ${SLABS}
key-cache-slabs: ${SLABS}

rrset-cache-size: ${RRSET_SIZE}m
msg-cache-size: ${MSG_SIZE}m

# compiled --with-libevent
outgoing-range: 8192
num-queries-per-thread: 4096

so-rcvbuf: ${SO_RCVBUF:-4}m
so-sndbuf: ${SO_SNDBUF:-4}m

so-reuseport: yes
EOF
}

convert_env() {
  local env_prefix
  local trim_length
  local conf_key
  local conf_value

  env_prefix="UNBOUND_${1}_"
  trim_length=${#env_prefix}

  for CONF_ENV in $(env | grep "${env_prefix}"); do
    conf_value=${CONF_ENV#*=}
    conf_key=$(echo ${CONF_ENV%%=*} \
      | sed -r \
        -e "s/.{${trim_length}}//" \
        -e 's/[\-_0-9]+$//' \
        -e 's/_/-/g' \
      | tr '[:upper:]' '[:lower:]' \
    )

    echo "${conf_key}: ${conf_value}"
  done
}

icann_bundle() {
  wget -q \
    -O "${1}" \
    "https://data.iana.org/root-anchors/icannbundle.pem"
  echo "CA bundle created: $1"
}

root_hints() {
  wget -q \
    -O "${1}" \
    "https://www.internic.net/domain/named.cache"
  echo "root zone hints created: $1"
}

root_trust_anchor() {
  if unbound-anchor \
    -r "${UNBOUND_HOME}/aux/root.hints" \
    -c "${UNBOUND_HOME}/aux/icannbundle.pem" \
    -a "${1}"; then
    echo "trust anchor created: $1"
  else
    echo "trust anchor already up-to-date: $1"
  fi
}

control_setup() {
  if test -s "${UNBOUND_HOME}/ssl/unbound_control.pem" \
    -a -s "${UNBOUND_HOME}/ssl/unbound_control.pem" \
    -a -n "${LAZY_CONTROL_SETUP+x}"; then
    echo "certificates already exist in $1"
  else
    unbound-control-setup \
      -d "${1}"
    echo "certificates created in $1"
  fi
}

fix_ownership() {
  # unbound writes key data during runtime, which requires
  # write access. if the directory is mounted as volume,
  # docker grants ownership to the root user.
  chown unbound:unbound "${UNBOUND_HOME}/aux" || true
}

if test $# -gt 0; then
  case "$1" in
    -*)
      # some option argument
      break
      ;;
    unbound)
      # remove argument as we prepend it later anyway
      shift
      ;;
    *)
      # command, unrelated to the purpose of this image
      exec "$@"
      ;;
  esac
fi

convert_env GLOBAL > "${GLOBAL_INCLUDE_D}/90_environment.conf"
convert_env SERVER > "${SERVER_INCLUDE_D}/90_environment.conf"
convert_env REMOTE > "${REMOTE_INCLUDE_D}/90_environment.conf"

if test -n "${ENABLE_CATCH_ALL+x}"; then
  catch_all_forwarder > "${GLOBAL_INCLUDE_D}/catch_all.conf"
  echo "catch-all forward zone config created"
fi

if test -n "${ENABLE_OPTIMIZATION+x}"; then
  server_optimization > "${SERVER_INCLUDE_D}/optimized.conf"
  echo "server optimization config created"
fi

if test -z "${DISABLE_CABUNDLE_CREATION+x}"; then
  icann_bundle "${UNBOUND_HOME}/aux/icannbundle.pem"
fi

if test -z "${DISABLE_HINTS_CREATION+x}"; then
  root_hints "${UNBOUND_HOME}/aux/root.hints"
fi

if test -z "${DISABLE_ANCHOR_CREATION+x}"; then
  root_trust_anchor "${UNBOUND_HOME}/aux/root.key"
fi

if test -z "${DISABLE_CONTROL_SETUP+x}"; then
  control_setup "${UNBOUND_HOME}/ssl"
fi

fix_ownership

exec unbound -d "$@"
