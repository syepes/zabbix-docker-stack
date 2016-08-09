# Usage:
#
# docker build --force-rm -t zabbix-db .
# docker run -d --name zabbix-db -h zabbix-db -p 5432:5432 zabbix-db
#
FROM       alpine:latest
MAINTAINER Sebastian YEPES <syepes@gmail.com>


ENV        LANG=en_US.UTF-8 \
           PG_INITDB_OPTS="-E UTF8 --locale='en_US.UTF-8'" \
           PGSQL_HOST=localhost \
           PGSQL_PORT=5432 \
           PGSQL_DB=zabbix \
           PGSQL_USER=zabbix \
           PGSQL_PASS=zabbix

RUN        echo "http://dl-4.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
           && echo "http://dl-4.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
           && echo "http://dl-4.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
           && apk add --no-cache tzdata sudo pwgen postgresql postgresql-client postgresql-libs zabbix-setup \
           && rm -f /etc/localtime && ln -s /usr/share/zoneinfo/UTC /etc/localtime \
           && apk del tzdata && rm -rf /var/cache/apk/*

RUN        mkdir -p /usr/share/zabbix/database/postgresql/partitions/
ADD        files/sql/* /usr/share/zabbix/database/postgresql/partitions/
ADD        files/*.sh /
RUN        chmod 755 /*.sh

# * Postgresql: 5432
EXPOSE     5432
VOLUME     ["/var/lib/pgsql"]
CMD        ["/run.sh"]

HEALTHCHECK --interval=15s --timeout=3s --retries=3 CMD sudo -u postgres pg_ctl status -D /var/lib/postgresql/9.5/data || exit 1

