#!/bin/sh -eu

PROGRAM=$(basename $0)
DB_URI=""
STAT_URI=""
DEBUG=false
JOURNAL=false
MAINCLASS=com.ubnt.ace.Launcher

: ${SYSTEM_IP:=""}
: ${DATADIR:=${UNIFI_HOME}/data}
: ${LOGDIR:=${UNIFI_HOME}/logs}
: ${RUNDIR:=${UNIFI_HOME}/run}
: ${DB_NAME:=unifi-ace}
: ${MONGO_HOST:=${MONGO_PORT_27017_TCP_ADDR:-mongo}}
: ${MONGO_PORT:=${MONGO_PORT_27017_TCP_PORT:-27017}}

usage() {
  cat <<EOF
Usage: $PROGRAM [-J] [-D] [-n NAME] [-u URI] [-s URI] [-i ADDRESS] [-r DIR] [-l DIR] [-d DIR] [-- JVM__EXTRA_OPTS]
       $PROGRAM -h

Launcher script for the UNIFI Controller application.

Options:

 -J         Enable MongoDB Database journaling (unifi.db.nojournal)
 -D         Raise log verbosity to debug level
 -n         Database name (unifi.db.name)
 -u         MongoDB connection URI (db.mongo.uri)
 -s         MongoDB connection URI for Statistics (statdb.mongo.uri)
 -i         Public IP address (system_ip)
 -r         Directory for runtime output
 -l         Directory for log output
 -d         Directory for application data

Environment:

 JVM_EXTRA_OPTS     Additional to pass to the Java interpreter

EOF
}

# @param String $1 config file
# @param String $2 config key
# @param String $3 config value
update_config() {
  sed -i \
    -e "/${2}/d" \
    -e "$ a ${2}=${3:-true}" \
    "${1}"
}

while getopts DJhr:l:d:n:u:s:i: OPT; do
  case "$OPT" in
    n)
      DB_NAME=$OPTARG
      ;;
    u)
      DB_URI=$OPTARG
      ;;
    s)
      STAT_URI=$OPTARG
      ;;
    i)
      SYSTEM_IP=$OPTARG
      ;;
    r)
      RUNDIR=$OPTARG
      ;;
    l)
      LOGDIR=$OPTARG
      ;;
    d)
      DATADIR=$OPTARG
      ;;
    J)
      JOURNAL=true
      ;;
    D)
      DEBUG=true
      ;;
    -)
      break;;
    [?h])
      usage
      exit 0
      ;;
    *)
      echo "Invalid argument '$OPT'"
      usage
      exit 1
      ;;
  esac
done
shift $(expr $OPTIND - 1)


FILE="${DATADIR}/system.properties"
JVM_OPTS="\
  -Dunifi.datadir=${DATADIR} \
  -Dunifi.logdir=${LOGDIR} \
  -Dunifi.rundir=${RUNDIR} \
  -Djava.awt.headless=true \
  -Dfile.encoding=UTF-8"

if test -z "${DB_URI}"; then
  DB_URI="mongodb://${MONGO_HOST}:${MONGO_PORT}/${DB_NAME}"
fi

if test -z "${STAT_URI}"; then
  STAT_URI="mongodb://${MONGO_HOST}:${MONGO_PORT}/${DB_NAME}_stat"
fi

# create config in case it does not exist yet
touch "$FILE"

update_config "$FILE" unifi.db.name "$DB_NAME"
update_config "$FILE" db.mongo.uri "$DB_URI"
update_config "$FILE" statdb.mongo.uri "$STAT_URI"

if $DEBUG; then
  update_config "$FILE" debug.system debug
fi

if ! $JOURNAL; then
  update_config "$FILE" unifi.db.nojournal true
fi

if test -n "${SYSTEM_IP}"; then
  update_config "$FILE" system_ip "$SYSTEM_IP"
fi

exec java -cp ${UNIFI_HOME}/lib/ace.jar \
  ${JVM_OPTS} ${JVM_EXTRA_OPTS:-} "$@" \
  ${MAINCLASS} start