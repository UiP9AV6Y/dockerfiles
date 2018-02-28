#!/bin/sh -eu

usage() {
  cat <<"EOF"
usage: docker run confgit [-s SHA1|-t TAG|-b BRANCH] URL [DIR]
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

  shift 1

  if test -d "${GIT_DIR}"; then
    git fetch "$@" "${SOURCE}"
    git fetch "$@" --tags "${SOURCE}"
  elif test -d "${GIT_WORK_TREE}"; then
    # clean GIT_WORK_TREE first
    find "${GIT_WORK_TREE}" -mindepth 1 -delete
    # despite the documentation, git cannot clone into an empty directory
    TARGET=$(mktemp -u -d)
    GIT_WORK_TREE="${TARGET}" git clone "$@" "${SOURCE}" "${GIT_DIR}"
    cp -r "${TARGET}/." "${GIT_WORK_TREE}"
  else
    git clone "$@" "${SOURCE}" "${GIT_DIR}"
  fi
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

REPO_SHA=''
REPO_TAG=''
REPO_BRANCH=''
GIT_ARGV=''

while getopts s:t:b:a:? OPT; do
  case "$OPT" in
    s)
      REPO_SHA=$OPTARG
      ;;
    t)
      REPO_TAG=$OPTARG
      ;;
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

: ${CONFGIT_SHA:=$REPO_SHA}
: ${CONFGIT_TAG:=$REPO_TAG}
: ${CONFGIT_BRANCH:=$REPO_BRANCH}
: ${CONFGIT_DIRECTORY:=$PWD}

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
export GIT_DIR=/.git
export GIT_WORK_TREE=${CONFGIT_DIRECTORY}
git_clone \
  "${CONFGIT_URL}" \
  ${GIT_ARGV}

if test -n "${CONFGIT_SHA}"; then
  git reset --hard "${CONFGIT_SHA}"
elif test -n "${CONFGIT_TAG}"; then
  git checkout -f "${CONFGIT_TAG}"
elif test -n "${CONFGIT_BRANCH}"; then
  git checkout -f "origin/${CONFGIT_BRANCH}"
else
  git checkout -f origin/HEAD
fi

if test -s "${CONFGIT_DIRECTORY}/.confgit/setup" -a -z "${CONFGIT_NO_HOOK+x}"; then
  cd ${CONFGIT_DIRECTORY} && \
  sh "${CONFGIT_DIRECTORY}/.confgit/setup" || true
fi

# we force remove it even if it was not executed
# or does not even exist; we do not want to leave
# any unnecessary files on the filesystem
rm -rf "${CONFGIT_DIRECTORY}/.confgit"

: