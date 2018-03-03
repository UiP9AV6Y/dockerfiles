#!/bin/sh
set -eu -o noglob

generate_scale_config() {
  local default_scale=$(nproc)
  local scale=${SERVER_COUNT:-$default_scale}
  local reuse='no'

  if test $scale -gt 1 -a -z "${DISABLE_REUSEPORT+x}"; then
    reuse='yes'
  fi

  sed -i -r \
    -e "s|^(\s+server-count):.+|\1: ${scale}|" \
    -e "s|^(\s+reuseport):.+|\1: ${reuse}|" \
    "$1"
}

format_key_config() {
  local key="${1}"
  local algorithm="${2:-hmac-sha256}"
  local default_secret=$(head -c 16 /dev/urandom | base64)
  local secret="${3:-$default_secret}"

  cat <<EOF
key:
  name: "${key}"
  algorithm: ${algorithm}
  secret: "${secret}"
EOF
}

generate_key_config() {
  sed -i '/# KEYS/,/# eo KEYS/d' "$1"
  echo '# KEYS' >> "$1"

  env | grep -E "^ACCESS_KEY_" | while read ACCESS_KEY; do
    format_key_config ${ACCESS_KEY#*=} >> "$1"
  done

  echo '# eo KEYS' >> "$1"
}

control_setup() {
  if test -s "${NSD_HOME}/ssl/nsd_control.pem" \
    -a -s "${NSD_HOME}/ssl/nsd_control.pem" \
    -a -n "${LAZY_CONTROL_SETUP+x}"; then
    echo "certificates already exist in $1"
  else
    nsd-control-setup \
      -d "${1}"
    echo "certificates created in $1"
  fi
}

if test $# -gt 0; then
  case "$1" in
    -*)
      # some option argument
      break
      ;;
    nsd)
      # remove argument as we prepend it later anyway
      shift
      ;;
    *)
      # command, unrelated to the purpose of this image
      exec "$@"
      ;;
  esac
fi

generate_key_config "${NSD_HOME}/nsd.conf"
generate_scale_config "${NSD_HOME}/nsd.conf"

if test -z "${DISABLE_CONTROL_SETUP+x}"; then
  control_setup "${NSD_HOME}/ssl"
fi

exec nsd -d "$@"