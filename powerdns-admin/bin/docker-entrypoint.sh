#!/bin/sh
set -eu

: ${POWERDNS_ADMIN_CONF:=${APP_HOME}/config.py}

args_to_array() {
  local a=''

  for arg in "$@"; do
    if test -z "$arg"; then
      continue
    elif test -z "$a"; then
      a="'$arg'"
    else
      a="${a}, '$arg'"
    fi
  done

  echo "[ ${a} ]"
}

setup_environment() {
  local config_path

  config_path=$(dirname "$POWERDNS_ADMIN_CONF")

  # config.py might not be located in APP_HOME (see #5)
  # PYTHONPATH might be empty
  export "PYTHONPATH=${PYTHONPATH+${PYTHONPATH}:}${config_path}"
}

setup_persistence() {
  export WAITFOR_DB=30

  python2 create_db.py

  if test -n "${POWERDNS_ADMIN_USERNAME+x}"; then
    python2 create_db_user.py
  fi
}

powerdns_admin_core_config() {
    local timeout=${POWERDNS_ADMIN_TIMEOUT:-10}
    local title=${POWERDNS_ADMIN_LOGIN_TITLE:-}
    local verbosity=${POWERDNS_ADMIN_LOG_LEVEL:-WARNING}

  cat << EOF >> "$1"
UPLOAD_DIR = '${APP_HOME}/uploads'
BIND_ADDRESS = '0.0.0.0'
PORT = 9393

LOGIN_TITLE = '${title}'
TIMEOUT = ${timeout}

LOG_LEVEL = '${verbosity}'
LOG_FILE = ''
EOF

  if test -n "${POWERDNS_ADMIN_BASIC_AUTH+x}"; then
    echo 'BASIC_ENABLED = True' >> "$1"
  else
    echo 'BASIC_ENABLED = False' >> "$1"
  fi

  if test -n "${POWERDNS_ADMIN_SIGNUP+x}"; then
    echo 'SIGNUP_ENABLED = True' >> "$1"
  else
    echo 'SIGNUP_ENABLED = False' >> "$1"
  fi

  if test -n "${POWERDNS_ADMIN_PRETTY_IPV6_PTR+x}"; then
    echo 'PRETTY_IPV6_PTR = True' >> "$1"
  else
    echo 'PRETTY_IPV6_PTR = False' >> "$1"
  fi
}

powerdns_admin_secret_config() {
  local secret_gen=$(head -c 1024 /dev/urandom | tr -cd '[:alnum:]' | head -c 64)
  local secret_key=${POWERDNS_ADMIN_SECRET_KEY:-${secret_gen}}

  echo "SECRET_KEY = '${secret_key}'" >> "$1"
}

powerdns_admin_edit_config() {
  local edit_default='SOA A AAAA CAA CNAME MX PTR SPF SRV TXT LOC NS PTR'
  local edit_records=$(args_to_array ${POWERDNS_ADMIN_RECORDS_ALLOW_EDIT:-${edit_default}})
  local edit_forward=$(args_to_array ${POWERDNS_ADMIN_FORWARD_RECORDS_ALLOW_EDIT:-${edit_default}})
  local edit_reverse=$(args_to_array ${POWERDNS_ADMIN_REVERSE_RECORDS_ALLOW_EDIT:-${edit_default}})

  cat << EOF >> "$1"
RECORDS_ALLOW_EDIT = ${edit_records}
FORWARD_RECORDS_ALLOW_EDIT = ${edit_forward}
REVERSE_RECORDS_ALLOW_EDIT = ${edit_reverse}
EOF
}

powerdns_admin_db_config() {
  local db_uri=${POWERDNS_ADMIN_DB_URI:-mysql://powerdns-admin:powerdns-admin@powerdns-admin/powerdns_admin}

  cat << EOF >> "$1"
SQLALCHEMY_DATABASE_URI = '${db_uri}'
SQLALCHEMY_MIGRATE_REPO = '${APP_HOME}/migrations/powerdns-admin'
SQLALCHEMY_TRACK_MODIFICATIONS = True
SQLALCHEMY_POOL_RECYCLE = 600
EOF
}

powerdns_admin_dns_config() {
  local dns_api=${POWERDNS_ADMIN_API_URL:-http://powerdns:8081/}
  local dns_key=${POWERDNS_ADMIN_API_KEY}

cat << EOF >> "$1"
PDNS_STATS_URL = '${dns_api}'
PDNS_API_KEY = '${dns_key}'
EOF

  if test -n "${POWERDNS_ADMIN_API_LEGACY+x}"; then
    echo "PDNS_VERSION = '3.4.2'" >> "$1"
  else
    echo "PDNS_VERSION = '4.0.0'" >> "$1"
  fi
}

powerdns_admin_saml_config() {
  local saml_meta=${POWERDNS_ADMIN_SAML_METADATA_URL}
  local saml_ttl=${POWERDNS_ADMIN_SAML_METADATA_CACHE_LIFETIME:-1}
  local saml_id=${POWERDNS_ADMIN_SAML_SP_ENTITY_ID}
  local saml_name=${POWERDNS_ADMIN_SAML_SP_CONTACT_NAME}
  local saml_mail=${POWERDNS_ADMIN_SAML_SP_CONTACT_MAIL}

  cat << EOF >> "$1"
SAML_PATH = '${APP_HOME}/saml'

SAML_METADATA_URL = '${saml_meta}'
SAML_METADATA_CACHE_LIFETIME = ${saml_ttl}
SAML_SP_ENTITY_ID = '${saml_id}'
SAML_SP_CONTACT_NAME = '${saml_name}'
SAML_SP_CONTACT_MAIL = '${saml_mail}'
EOF

  if test -n "${POWERDNS_ADMIN_SAML_DEBUG+x}"; then
    echo 'SAML_DEBUG = True' >> "$1"
  else
    echo 'SAML_DEBUG = False' >> "$1"
  fi

  if test -n "${POWERDNS_ADMIN_SAML_LOGOUT+x}"; then
    echo 'SAML_LOGOUT = True' >> "$1"
  else
    echo 'SAML_LOGOUT = False' >> "$1"
  fi

  if test -n "${POWERDNS_ADMIN_SAML_SIGN_REQUEST+x}"; then
    echo 'SAML_SIGN_REQUEST = True' >> "$1"
  else
    echo 'SAML_SIGN_REQUEST = False' >> "$1"
  fi
}

powerdns_admin_google_config() {
  local google_scope=${POWERDNS_ADMIN_GOOGLE_SCOPE:-email profile}
  local google_api=${POWERDNS_ADMIN_GOOGLE_API_URL:-https://www.googleapis.com/oauth2/v1/}
  local google_token=${POWERDNS_ADMIN_GOOGLE_TOKEN_URL:-https://accounts.google.com/o/oauth2/token}
  local google_auth=${POWERDNS_ADMIN_GOOGLE_AUTH_URL:-https://accounts.google.com/o/oauth2/auth}
  local google_redir=${POWERDNS_ADMIN_GOOGLE_REDIRECT_URI:-/user/authorized}
  local google_key=${POWERDNS_ADMIN_GOOGLE_KEY}
  local google_secret=${POWERDNS_ADMIN_GOOGLE_SECRET}

  cat << EOF >> "$1"
GOOGLE_OAUTH_CLIENT_ID = '${google_key}'
GOOGLE_OAUTH_CLIENT_SECRET = '${google_secret}'
GOOGLE_REDIRECT_URI = '${google_redir}'
GOOGLE_BASE_URL='${google_api}'
GOOGLE_TOKEN_URL = '${google_token}'
GOOGLE_TOKEN_PARAMS = {
    'scope': '${google_scope}'
}
GOOGLE_AUTHORIZE_URL='${google_auth}'
EOF
}

powerdns_admin_github_config() {
  local gh_scope=${POWERDNS_ADMIN_GITHUB_SCOPE:-email}
  local gh_api=${POWERDNS_ADMIN_GITHUB_API_URL:-https://api.github.com/}
  local gh_token=${POWERDNS_ADMIN_GITHUB_TOKEN_URL:-https://github.com/login/oauth/access_token}
  local gh_auth=${POWERDNS_ADMIN_GITHUB_AUTH_URL:-https://github.com/login/oauth/authorize}
  local gh_key=${POWERDNS_ADMIN_GITHUB_KEY}
  local gh_secret=${POWERDNS_ADMIN_GITHUB_SECRET}

  cat << EOF >> "$1"
GITHUB_OAUTH_KEY = '${gh_key}'
GITHUB_OAUTH_SECRET = '${gh_secret}'
GITHUB_OAUTH_SCOPE = '${gh_scope}'
GITHUB_OAUTH_URL = '${gh_api}'
GITHUB_OAUTH_TOKEN = '${gh_token}'
GITHUB_OAUTH_AUTHORIZE = '${gh_auth}'
EOF
}
powerdns_admin_ldap_config() {
  local ldap_type=${POWERDNS_ADMIN_LDAP_TYPE:-ldap}
  local ldap_uri=${POWERDNS_ADMIN_LDAP_URI:-ldaps://ldap:636}
  local ldap_user=${POWERDNS_ADMIN_LDAP_BIND_DN:-}
  local ldap_pass=${POWERDNS_ADMIN_LDAP_BIND_PW:-}
  local ldap_field=${POWERDNS_ADMIN_LDAP_USERNAME_FIELD:-uid}
  local ldap_filter=${POWERDNS_ADMIN_LDAP_FILTER:-(objectClass=inetorgperson)}
  local ldap_search=${POWERDNS_ADMIN_LDAP_SEARCH_BASE}
  local ldap_admin_group=${POWERDNS_ADMIN_LDAP_ADMIN_GROUP}
  local ldap_user_group=${POWERDNS_ADMIN_LDAP_USER_GROUP}

  cat << EOF >> "$1"
LDAP_TYPE = '${ldap_type}'
LDAP_URI = '${ldap_uri}'
LDAP_USERNAME = '${ldap_user}'
LDAP_PASSWORD = '${ldap_pass}'
LDAP_SEARCH_BASE = '${ldap_search}'
LDAP_USERNAMEFIELD = '${ldap_field}'
LDAP_FILTER = '${ldap_filter}'
LDAP_ADMIN_GROUP = '${ldap_admin_group}'
LDAP_USER_GROUP = '${ldap_user_group}'
EOF

  if test -n "${POWERDNS_ADMIN_LDAP_GROUP_SECURITY+x}"; then
    echo 'LDAP_GROUP_SECURITY = True' >> "$1"
  else
    echo 'LDAP_GROUP_SECURITY = False' >> "$1"
  fi
}

if test $# -gt 0; then
  case "$1" in
    -*)
      # some option argument
      break
      ;;
    uwsgi)
      # remove argument as we prepend it later anyway
      shift
      ;;
    *)
      # command, unrelated to the purpose of this image
      exec "$@"
      ;;
  esac
fi

printf '# %s\n\n' "$(date)" > "${POWERDNS_ADMIN_CONF}"
powerdns_admin_core_config "${POWERDNS_ADMIN_CONF}"
powerdns_admin_db_config "${POWERDNS_ADMIN_CONF}"
powerdns_admin_dns_config "${POWERDNS_ADMIN_CONF}"
powerdns_admin_edit_config "${POWERDNS_ADMIN_CONF}"
powerdns_admin_secret_config "${POWERDNS_ADMIN_CONF}"

if test -n "${POWERDNS_ADMIN_LDAP_ENABLED+x}"; then
  powerdns_admin_ldap_config "${POWERDNS_ADMIN_CONF}"
fi

if test -n "${POWERDNS_ADMIN_GITHUB_ENABLED+x}"; then
  echo 'GITHUB_OAUTH_ENABLE = True' >> "${POWERDNS_ADMIN_CONF}"
  powerdns_admin_github_config "${POWERDNS_ADMIN_CONF}"
else
  echo 'GITHUB_OAUTH_ENABLE = False' >> "${POWERDNS_ADMIN_CONF}"
fi

if test -n "${POWERDNS_ADMIN_GOOGLE_ENABLED+x}"; then
  echo 'GOOGLE_OAUTH_ENABLE = True' >> "${POWERDNS_ADMIN_CONF}"
  powerdns_admin_google_config "${POWERDNS_ADMIN_CONF}"
else
  echo 'GOOGLE_OAUTH_ENABLE = False' >> "${POWERDNS_ADMIN_CONF}"
fi

if test -n "${POWERDNS_ADMIN_SAML_ENABLED+x}"; then
  echo 'SAML_ENABLED = True' >> "${POWERDNS_ADMIN_CONF}"
  powerdns_admin_saml_config "${POWERDNS_ADMIN_CONF}"
else
  echo 'SAML_ENABLED = False' >> "${POWERDNS_ADMIN_CONF}"
fi

setup_environment
setup_persistence

exec uwsgi \
  --uid www-data \
  --gid www-data \
  --plugin python \
  --manage-script-name \
  --mount ${UWSGI_BASE_URI:-/}=run:app \
  --protocol "${UWSGI_PROTOCOL:-http}" \
  --socket :9393 \
  --stats :9191 \
  "$@"
