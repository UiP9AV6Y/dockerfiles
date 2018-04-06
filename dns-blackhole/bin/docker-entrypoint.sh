#!/bin/sh
set -eu

usage() {
  echo "usage: docker dns-blackhole [-f FORMAT|-s SYSTEM] -o FILE"
}

parse_env_values() {
  env | grep -E "^$1" | while read ENV_KEY_VALUE; do
    echo "${ENV_KEY_VALUE}" | cut -d= -f2
  done
}

dnsbh_hosts_fragment() {
  parse_env_values "DNSBH_HOSTS_" | while read DNSBH_HOSTS_PROVIDER; do
    echo "        - '${DNSBH_HOSTS_PROVIDER}'" >> "$1"
  done
}

dnsbh_easylist_fragment() {
  parse_env_values "DNSBH_EASYLIST_" | while read DNSBH_EASYLIST_PROVIDER; do
    echo "        - '${DNSBH_EASYLIST_PROVIDER}'" >> "$1"
  done
}

dnsbh_disconnect_fragment() {
  for DNSBH_DISCONNECT_CATEGORY in ${DNSBH_DISCONNECT_CATEGORIES:-}; do
    DNSBH_DISCONNECT_CAT=$(echo "${DNSBH_DISCONNECT_CATEGORY}" | cut -d= -f2)
    echo "          - ${DNSBH_DISCONNECT_CAT}" >> "$1"
  done
}

if test $# -gt 0; then
  case "$1" in
    -*)
      # some option argument
      ;;
    dns-blackhole)
      # remove argument as we prepend it later anyway
      shift 1
      ;;
    *)
      # command, unrelated to the purpose of this image
      exec "$@"
      ;;
  esac
fi

OUTPUT_FILE=''
OUTPUT_SYSTEM=''
OUTPUT_FORMAT=''

while getopts o:s:f:? OPT; do
  case "$OPT" in
    o)
      OUTPUT_FILE="${OPTARG}"
      ;;
    s)
      OUTPUT_SYSTEM="${OPTARG}"
      ;;
    f)
      OUTPUT_FORMAT="${OPTARG}"
      ;;
    [?])
      usage
      exit 0
      ;;
  esac
done
shift $(expr $OPTIND - 1)

case "$OUTPUT_SYSTEM" in
  # the /etc/hosts file is managed by the docker engine;
  # modifying it is not recommended, so we do not provide
  # any support for it for now
  # hosts)
  #   OUTPUT_FORMAT='0.0.0.0 {domain}'
  #   ;;
  dnsmasq)
    OUTPUT_FORMAT='server=/{domain}/'
    ;;
  unbound)
    OUTPUT_FORMAT='local-zone: "{domain}" always_nxdomain'
    ;;
  unbound-server)
    #   identation in the output file (1 tab)
    # + the YAML config alignment (3 tabs)
    OUTPUT_FORMAT='server:
        local-zone: "{domain}" always_nxdomain'
    ;;
  powerdns)
    OUTPUT_FORMAT='{domain}='
    ;;
  '')
    ;;
  *)
    echo "unsupported system '${OUTPUT_SYSTEM}'" 1>&2
    exit 1
    ;;
esac

: ${DNSBH_WHITELIST:=/etc/dns-blackhole/whitelist}
: ${DNSBH_BLACKLIST:=/etc/dns-blackhole/blacklist}
: ${DNSBH_CONFIG:=/etc/dns-blackhole/dns-blackhole.yml}
: ${DNSBH_FILE:=${OUTPUT_FILE}}
: ${DNSBH_DATA:=${OUTPUT_FORMAT}}

HOSTS_FRAGMENT=$(mktemp)
EASYLIST_FRAGMENT=$(mktemp)
DISCONNECT_FRAGMENT=$(mktemp)

if test -z "${DNSBH_FILE}"; then
  echo "no output file (DNSBH_FILE) defined" 1>&2
  exit 1
fi

if test -z "${DNSBH_DATA}"; then
  echo "no output format (DNSBH_DATA) defined" 1>&2
  exit 1
fi

parse_env_values "DNSBH_BLACKLISTED_" > "${DNSBH_BLACKLIST}"
parse_env_values "DNSBH_WHITELISTED_" > "${DNSBH_WHITELIST}"

cat <<EOF | tee "${DNSBH_CONFIG}" >/dev/null
---

dns-blackhole:
  general:
    cache: /var/cache/dns-blackhole
    whitelist: '${DNSBH_WHITELIST}'
    blacklist: '${DNSBH_BLACKLIST}'
  config:
    zone_file: '${DNSBH_FILE}'
    zone_data: |
      ${DNSBH_DATA}
    blackhole_lists:
EOF

dnsbh_hosts_fragment "$HOSTS_FRAGMENT"
dnsbh_easylist_fragment "$EASYLIST_FRAGMENT"
dnsbh_disconnect_fragment "$DISCONNECT_FRAGMENT"

if test -s "$HOSTS_FRAGMENT"; then
  echo "      hosts:" >> "${DNSBH_CONFIG}"
  cat "$HOSTS_FRAGMENT" >> "${DNSBH_CONFIG}"
fi

if test -s "$EASYLIST_FRAGMENT"; then
  echo "      easylist:" >> "${DNSBH_CONFIG}"
  cat "$EASYLIST_FRAGMENT" >> "${DNSBH_CONFIG}"
fi

if test -n "${DNSBH_DISCONNECT_URL+x}"; then
  echo "      disconnect:" >> "${DNSBH_CONFIG}"
  echo "        url: '${DNSBH_DISCONNECT_URL}'" >> "${DNSBH_CONFIG}"

  if test -s "$DISCONNECT_FRAGMENT"; then
    echo "        categories:" >> "${DNSBH_CONFIG}"
    cat "$DISCONNECT_FRAGMENT" >> "${DNSBH_CONFIG}"
  fi
fi

exec dns-blackhole