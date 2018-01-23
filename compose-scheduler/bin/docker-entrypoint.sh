#!/bin/sh
set -eu -o noglob

# SERVICE ACTION CRONTAB...
schedule_job() {
  SCHEDULE_SERVICE=""
  SCHEDULE_ACTION=""
  SCHEDULE_COMMENT=""
  SCHEDULE_TIMER=""

  : ${SCHEDULER_WORKDIR:=$PWD}

  if test $# -eq 0; then
      echo "Missing docker-compose service name" 1>&2
      exit 1
  else
    SCHEDULE_SERVICE="$1"
    shift
  fi

  if test $# -eq 0; then
    SCHEDULE_ACTION="start"
  else
    SCHEDULE_ACTION="$1"
    shift
  fi

  case $# in
    0)
      SCHEDULE_TIMER="* * * * *"
      ;;
    1)
      case "$1" in
        @reboot)
          echo "Unsupported crontab '$@'" 1>&2
          exit 1
          ;;
        @yearly|@annually)
          SCHEDULE_TIMER="0 0 1 1 *"
          ;;
        @monthly)
          SCHEDULE_TIMER="0 0 1 * *"
          ;;
        @weekly)
          SCHEDULE_TIMER="0 0 * * 0"
          ;;
        @daily|@midnight)
          SCHEDULE_TIMER="0 0 * * *"
          ;;
        @hourly)
          SCHEDULE_TIMER="0 * * * *"
          ;;
        @minutely)
          SCHEDULE_TIMER="* * * * *"
          ;;
        @*)
          echo "Invalid crontab '$@'" 1>&2
          exit 1
          ;;
        *)
          SCHEDULE_TIMER="$1 * * * *"
          ;;
      esac
      ;;
    2)
      SCHEDULE_TIMER="$1 $2 * * *"
      ;;
    3)
      SCHEDULE_TIMER="$1 $2 $3 * *"
      ;;
    4)
      SCHEDULE_TIMER="$1 $2 $3 $4 *"
      ;;
    5)
      SCHEDULE_TIMER="$1 $2 $3 $4 $5"
      ;;
    *)
      echo "Invalid crontab '$@'" 1>&2
      exit 1
      ;;
  esac

  case "$SCHEDULE_ACTION" in
    build)
      SCHEDULE_COMMENT="Build or rebuild"
        ;;
    create)
      SCHEDULE_COMMENT="Create"
        ;;
    pause)
      SCHEDULE_COMMENT="Pause"
      ;;
    pull)
      SCHEDULE_COMMENT="Pull image for"
      ;;
    push)
      SCHEDULE_COMMENT="Push image for"
      ;;
    restart)
      SCHEDULE_COMMENT="Restart"
      ;;
    scale)
      SCHEDULE_COMMENT="Set number of containers for"
      ;;
    start)
      SCHEDULE_COMMENT="Start"
      ;;
    stop)
      SCHEDULE_COMMENT="Stop"
      ;;
    unpause)
      SCHEDULE_COMMENT="Unpause"
      ;;
    *)
      echo "Schedule action '$SCHEDULE_ACTION' is not supported" 1>&2
      exit 1
      ;;
  esac

  echo "# $SCHEDULE_COMMENT $SCHEDULE_SERVICE"
  echo "${SCHEDULE_TIMER} cd $SCHEDULER_WORKDIR && docker-compose $SCHEDULE_ACTION $SCHEDULE_SERVICE 2>&1 >/dev/null"
}

if test $# -gt 0; then
  case "$1" in
    -*)
      # some option argument
      break
      ;;
    crond)
      # remove argument as we prepend it later anyway
      shift
      ;;
    *)
      # command, unrelated to the purpose of this image
      exec "$@"
      ;;
  esac
fi

CRONTAB_FILE=$(mktemp)

cat <<EOF | tee $CRONTAB_FILE >/dev/null
# created on $(date -u -R)

# health checkpoint
* * * * * touch -m /var/run/cron.lastrun
EOF

env | grep -E "^SCHEDULE_" | while read SCHEDULE; do
  schedule_job $(echo $SCHEDULE | cut -d= -f2) | tee -a $CRONTAB_FILE >/dev/null
done

crontab $CRONTAB_FILE

exec crond -f "$@"