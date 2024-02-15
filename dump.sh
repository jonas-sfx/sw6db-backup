#!/bin/sh

## filename     dump.sh
## description: create dumps with week/weekday as filename
## author:      jonas@sfxonline.de
## =======================================================================

cd "$(dirname "$0")" || exit

# CREDENTIALS
MYSQL=$(grep -Po 'DATABASE_URL=\K.*' ../project-root/.env)
USER="$(echo "$MYSQL" | grep -Po 'mysql://\K[^:]+')"
pwdgrep="mysql://$USER:\K[^@]+"
PASSWORD="$(echo "$MYSQL" | grep -Po "$pwdgrep")"
HOST="$(echo "$MYSQL" | grep -oP '@[^:\/]+' | cut -d@ -f2)"
PORT="$(echo "$MYSQL" | grep -oP '@.*:[0-9]+' | cut -d: -f2)"
DB="$(echo "$MYSQL" | grep -oP '/[^\/]+$' | cut -d/ -f2)"

STR_WEEKDAY=$(date +%a)".tar.gz"
STR_WEEK=$(date +%U)".tar.gz"
MYSQLDUMP='/usr/local/mysql/bin/mysqldump'

# CHECK FOR EXISTING FILES
MAKEW=0
MAKED=0

if test -f "archive/$STR_WEEKDAY"; then
    echo "$STR_WEEKDAY exists."
    if [ $(stat --format=%Y archive/"$STR_WEEKDAY") -le $(( $(date +%s) - 3600*24*6 )) ]; then 
        echo "$STR_WEEKDAY to old."
        MAKED=1
    fi
else
    echo "$STR_WEEKDAY does not exist."
    MAKED=1
fi

if test -f "archive/$STR_WEEK"; then
    echo "$STR_WEEK exists."
    if [ $(stat --format=%Y archive/"$STR_WEEK") -le $(( $(date +%s) - 3600*24*350 )) ]; then 
        echo "$STR_WEEK to old."
        MAKEW=1
    fi
else
    echo "$STR_WEEK does not exist."
    MAKEW=1
fi

# MAKE THE DUMPs you need.
if [[ $(($MAKEW  + $MAKED)) -gt 0 ]]; then
  $MYSQLDUMP -u"$USER" -p"$PASSWORD" -h"$HOST" -P "$PORT" --no-tablespaces --hex-blob "$DB" > last-dump.sql

  if [ $MAKEW -gt 0 ]; then
    tar -czf "archive/$STR_WEEK" last-dump.sql
  fi

  if [ $MAKED -gt 0 ]; then
    tar -czf "archive/$STR_WEEKDAY" last-dump.sql
  fi

  rm last-dump.sql
fi

