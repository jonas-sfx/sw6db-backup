#!/bin/sh

## filename     restore.sh
## description: restore dumps with week/weekday as filename
## author:      jonas@sfxonline.de
## =======================================================================

cd "$(dirname "$0")"

# CREDENTIALS
MYSQL=$(grep -Po 'DATABASE_URL=\K.*' ../project-root/.env)
USER="$(echo $MYSQL | grep -Po 'mysql://\K[^:]+')"
pwdgrep="mysql://$USER:\K[^@]+"
PASSWORD="$(echo $MYSQL | grep -oP $pwdgrep)"
HOST="$(echo $MYSQL | grep -oP '@[^:\/]+' | cut -d@ -f2)"
PORT="$(echo $MYSQL | grep -oP '@.*:[0-9]+' | cut -d: -f2)"
DB="$(echo $MYSQL | grep -oP '/[^\/]+$' | cut -d/ -f2)"

if test -f "archive/$1.tar.gz"; then
    echo "Backup $1.tar.gz exists."
    cd archive/
    tar -xzf $1.tar.gz
    sed 's/\sDEFINER=`[^`]*`@`[^`]*`//g' -i last-dump.sql
    mysql  --default-character-set=utf8mb4 -u"$USER" -p"$PASSWORD" -h"$HOST" -P $PORT $DB < last-dump.sql
    # echo "mysql  -u\"$USER\" -p\"$PASSWORD\" -h\"$HOST\" -P $PORT $DB < last-dump.sql"
    rm last-dump.sql
    exit 0
else
  echo "Backup $1.tar.gz does not exist."
fi
