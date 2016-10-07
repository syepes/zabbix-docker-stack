#!/bin/sh
set -e

PGSQL_DB=${PGSQL_DB:="zabbix"}
PGSQL_USER=${PGSQL_USER:="zabbix"}
PGSQL_PASS=${PGSQL_PASS:-}
PG_DATDIR="/var/lib/postgresql/${DB_VER}/data"
PG_BINDIR="/usr/bin"


__create_database() {
echo "******CREATING ZABBIX PROXY DATABASE******"

if [ -z "$(ls -A "$PG_DATDIR")" ]; then
  echo "> Init postgres"
  sudo -u postgres $PG_BINDIR/initdb -D $PG_DATDIR

  { echo; echo "host all all 0.0.0.0/0 md5"; } >> "$PG_DATDIR"/pg_hba.conf
  sed -e "s/^#?(listen_addresses\s*=\s*)\S+/\1'*'/" \
      -e "s/^#?(logging_collector\s*=\s*)\S+/\1on/" -ri "$PG_DATDIR"/postgresql.conf

  echo "> Starting postgres"
  sudo -u postgres $PG_BINDIR/pg_ctl -w start -D $PG_DATDIR

else
  echo "> Starting postgres"
  sudo -u postgres $PG_BINDIR/pg_ctl -w start -D $PG_DATDIR

  DB_INSTALLED=`sudo -u postgres psql -l | grep -c ${PGSQL_DB}`
  if [ $DB_INSTALLED -ne 0 ]; then
    echo "> Zabbix Database (${PGSQL_DB}) already exists, nothing to do in this script"
    echo "> Stopping postgres"
    sudo -u postgres $PG_BINDIR/pg_ctl stop -D $PG_DATDIR
    echo "> Stopped postgres"
    exit 0
  fi
fi

echo "> Zabbix Database creation"

# Check to see if we have pre-defined credentials to use
if [ -n "${PGSQL_USER}" ]; then
  if [ -z "${PGSQL_PASS}" ]; then
    echo ""
    echo "WARNING: "
    echo "No password specified for \"${PGSQL_USER}\". Generating one"
    echo ""
    PGSQL_PASS=$(pwgen -c -n -1 12)
    echo "Password for \"${PGSQL_USER}\" created as: \"${PGSQL_PASS}\""
  fi
  echo "  Creating Role/User: ${PGSQL_USER} with Password: ${PGSQL_PASS}"
  sudo -u postgres psql -c "CREATE ROLE ${PGSQL_USER} WITH CREATEROLE SUPERUSER LOGIN PASSWORD '${PGSQL_PASS}';"
fi

if [ -n "${PGSQL_DB}" ]; then
  echo "> Creating database \"${PGSQL_DB}\"..."
  sudo -u postgres psql -c "CREATE DATABASE ${PGSQL_DB} WITH OWNER=${PGSQL_USER} ENCODING='UTF8' lc_collate='en_US.UTF-8' lc_ctype='en_US.UTF-8';"
fi
if [ -n "${PGSQL_USER}" ]; then
  echo "> Granting access to database \"${PGSQL_DB}\" for user \"${PGSQL_USER}\"..."
  sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE ${PGSQL_DB} to ${PGSQL_USER};"
fi

echo "  Populating the Database: ${PGSQL_DB}"
sudo -u postgres psql -U ${PGSQL_USER} -d ${PGSQL_DB} -f /usr/share/zabbix/database/postgresql/schema.sql
sudo -u postgres psql -U ${PGSQL_USER} -d ${PGSQL_DB} -f /usr/share/zabbix/database/postgresql/images.sql
sudo -u postgres psql -U ${PGSQL_USER} -d ${PGSQL_DB} -f /usr/share/zabbix/database/postgresql/data.sql

echo "  Activating table partitioning on Database: ${PGSQL_DB}"
sudo -u postgres psql -U ${PGSQL_USER} -d ${PGSQL_DB} -f /usr/share/zabbix/database/postgresql/partitions/01_create_partitions_schema.sql
sudo -u postgres psql -U ${PGSQL_USER} -d ${PGSQL_DB} -f /usr/share/zabbix/database/postgresql/partitions/02_create_main_function.sql
sudo -u postgres psql -U ${PGSQL_USER} -d ${PGSQL_DB} -f /usr/share/zabbix/database/postgresql/partitions/03_create_triggers_for_tables.sql
sudo -u postgres psql -U ${PGSQL_USER} -d ${PGSQL_DB} -f /usr/share/zabbix/database/postgresql/partitions/04_create_remove_functions.sql

echo "> Stopping postgres"
sudo -u postgres $PG_BINDIR/pg_ctl stop -D $PG_DATDIR
echo "> Stopped postgres"
}

__start_database() {
echo "> Start postgres"
chown -R postgres:postgres /var/lib/postgresql
sudo -u postgres $PG_BINDIR/postgres -D $PG_DATDIR &
wait
}

__stop_database() {
echo "> Stopping postgres : SIGTERM signal received, try to gracefully shutdown all services..."
sudo -u postgres $PG_BINDIR/pg_ctl stop -m fast -D $PG_DATDIR
}


trap "__stop_database; exit 0" SIGTERM SIGINT



__create_database 2>&1 | tee -a /tmp/create_database.log
__start_database

