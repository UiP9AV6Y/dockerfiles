#!/bin/sh -eu

usage() {
  cat <<"EOF"
usage: docker run confgit [-b BRANCH] URL [DIR]
EOF
}

setup_identity() {
  SSH_CONFIG="$1"
  SSH_IDENTITY="$2"

  if test -n "${CONFGIT_IDENTITY_SECRET+x}"; then
    if test -s "/run/secrets/${CONFGIT_IDENTITY_SECRET}"; then
      cat "/run/secrets/${CONFGIT_IDENTITY_SECRET}" \
        > "${SSH_IDENTITY}"
    else
      echo "Unable to read identity from secret ${CONFGIT_IDENTITY_SECRET}" 1>&2
      exit 1
    fi
  elif test -n "${CONFGIT_IDENTITY_FILE+x}"; then
    if test -s "${CONFGIT_IDENTITY_FILE}"; then
      cat "${CONFGIT_IDENTITY_FILE}" \
        > "${SSH_IDENTITY}"
    else
      echo "Unable to read identity from file ${CONFGIT_IDENTITY_FILE}" 1>&2
      exit 1
    fi
  elif test -n "${CONFGIT_IDENTITY+x}"; then
    echo "${CONFGIT_IDENTITY}" \
      > "${SSH_IDENTITY}"
  fi

  if test -s "${SSH_IDENTITY}"; then
    echo "  IdentityFile ${SSH_IDENTITY}" \
      >> "${SSH_CONFIG}"
  fi
}

setup_user() {
  SSH_CONFIG="$1"

  if test -n "${CONFGIT_USERNAME_SECRET+x}"; then
    if test -s "/run/secrets/${CONFGIT_USERNAME_SECRET}"; then
      printf '  User ' \
        >> "${SSH_CONFIG}"
      sed -e '$a\' "/run/secrets/${CONFGIT_USERNAME_SECRET}" \
        >> "${SSH_CONFIG}"
    else
      echo "Unable to read username from secret ${CONFGIT_USERNAME_SECRET}" 1>&2
      exit 1
    fi
  elif test -n "${CONFGIT_USERNAME_FILE+x}"; then
    if test -s "${CONFGIT_USERNAME_FILE}"; then
      printf '  User ' \
        >> "${SSH_CONFIG}"
      sed -e '$a\' "${CONFGIT_USERNAME_FILE}" \
        >> "${SSH_CONFIG}"
    else
      echo "Unable to read username from file ${CONFGIT_USERNAME_FILE}" 1>&2
      exit 1
    fi
  elif test -n "${CONFGIT_USERNAME+x}"; then
    echo "  User ${CONFGIT_USERNAME}" \
      >> "${SSH_CONFIG}"
  fi
}

setup_ssh() {
  SSH_DIR="$1"

  install \
    -d \
    -m 0700 \
    "${SSH_DIR}"
  cat <<"EOF" | tee "${SSH_DIR}/config" >/dev/null
Host *
  BatchMode yes
  CheckHostIP no
  VerifyHostKeyDNS no
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
  ConnectionAttempts 3
  ConnectTimeout 10
EOF

  for CONFGIT_SSH_OPTION in ${CONFGIT_SSH_OPTIONS:-}; do
    echo "  ${CONFGIT_SSH_OPTION}" \
      | tr '=' ' ' >> "${SSH_DIR}/config"
  done

  touch "${SSH_DIR}/identity"
  chmod 0400 \
    "${SSH_DIR}/config" \
    "${SSH_DIR}/identity"

  setup_user \
    "${SSH_DIR}/config"
  setup_identity \
    "${SSH_DIR}/config" \
    "${SSH_DIR}/identity"
}

git_clone() {
  SOURCE="$1"
  TARGET="$2"

  shift 2

  if test -d "${TARGET}"; then
    # deleting and recreating the directory
    # might not work if it is a shared docker volume
    find "${TARGET}" -mindepth 1 -delete
  fi

  git clone "$@" \
    "${SOURCE}" \
    "${TARGET}"

  # alternatively we could fiddle around with
  # GIT_DIR/GIT_WORK_TREE or --separate-git-dir
  rm -rf "${TARGET}/.git"
}

if test $# -gt 0; then
  case "$1" in
    -*)
      # some option argument
      ;;
    *://*)
      # repository URL
      ;;
    *)
      # command, unrelated to the purpose of this image
      exec "$@"
      ;;
  esac
fi

REPO_BRANCH=''
GIT_ARGV='--depth 1'

while getopts b:a:? OPT; do
  case "$OPT" in
    b)
      REPO_BRANCH=$OPTARG
      ;;
    a)
      GIT_ARGV="${GIT_ARGV} ${OPTARG}"
      ;;
    [?])
      usage
      exit 0
      ;;
  esac
done
shift $(expr $OPTIND - 1)

: ${CONFGIT_BRANCH:=$REPO_BRANCH}
: ${CONFGIT_DIRECTORY:=$PWD}

if test -n "${CONFGIT_BRANCH}"; then
  GIT_ARGV="${GIT_ARGV} --branch ${CONFGIT_BRANCH}"
fi

if test $# -gt 0;then
  CONFGIT_URL="$1"
elif test -z "${CONFGIT_URL+x}"; then
  echo 'no repository URL provided' 1>&2
  usage 1>&2
  exit 1
fi

if test $# -gt 1; then
  CONFGIT_DIRECTORY="$2"
fi

setup_ssh "${HOME}/.ssh"
git_clone \
  "${CONFGIT_URL}" \
  "${CONFGIT_DIRECTORY}" \
  ${GIT_ARGV}

if test -s "${CONFGIT_DIRECTORY}/.confgit/setup" -a -z "${CONFGIT_NO_HOOK+x}"; then
  cd ${CONFGIT_DIRECTORY} && \
  sh "${CONFGIT_DIRECTORY}/.confgit/setup" || true
fi

# we force remove it even if it was not executed
# or does not even exist; we do not want to leave
# any unnecessary files on the filesystem
rm -rf "${CONFGIT_DIRECTORY}/.confgit"

: