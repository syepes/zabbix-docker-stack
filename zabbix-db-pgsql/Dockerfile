# Usage:
#
# docker build --force-rm -t zabbix-db .
# docker run -d --name zabbix-db -h zabbix-db -p 5432:5432 zabbix-db
#
FROM        alpine:latest
MAINTAINER  Sebastian YEPES <syepes@gmail.com>

ARG         APK_FLAGS_COMMON="-q"
ARG         APK_FLAGS_PERSISTANT="${APK_FLAGS_COMMON} --clean-protected --no-cache"
ARG         APK_FLAGS_DEV="${APK_FLAGS_COMMON} --no-cache"
ARG         DB_TYPE=postgresql
ARG         ZBX_SOURCES="http://sourceforge.net/projects/zabbix/files/ZABBIX%20Latest%20Stable/3.2.1/zabbix-3.2.1.tar.gz/download"

ENV         LANG=en_US.UTF-8 \
            TERM=xterm \
            ZBX_SOURCES=${ZBX_SOURCES} \
            DB_TYPE=${DB_TYPE} \
            DB_VER=9.6 \
            PG_INITDB_OPTS="-E UTF8 --locale='en_US.UTF-8'" \
            PGSQL_HOST=localhost \
            PGSQL_PORT=5432 \
            PGSQL_DB=zabbix \
            PGSQL_USER=zabbix \
            PGSQL_PASS=zabbix

RUN         echo "http://dl-4.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
            && echo "http://dl-4.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
            && echo "http://dl-4.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
            && apk update \
            && apk add ${APK_FLAGS_PERSISTANT} sudo pwgen postgresql postgresql-client postgresql-libs \
            && apk add ${APK_FLAGS_DEV} --virtual build-deps tzdata curl tar \
            && rm -f /etc/localtime && ln -s /usr/share/zoneinfo/UTC /etc/localtime \
            && mkdir -p /tmp/zabbix/ /usr/share/zabbix/database/${DB_TYPE}/ \
            && curl -#SL "${ZBX_SOURCES}" | tar -xz -C /tmp/zabbix --strip-components 1 \
            && cp -r /tmp/zabbix/database/${DB_TYPE}/* /usr/share/zabbix/database/${DB_TYPE}/ \
            && apk del ${APK_FLAGS_COMMON} --purge build-deps \
            && rm -rf /var/cache/apk/* /tmp/zabbix/

RUN         mkdir -p /usr/share/zabbix/database/postgresql/partitions/
ADD         files/sql/* /usr/share/zabbix/database/postgresql/partitions/
ADD         files/*.sh /
RUN         chmod 755 /*.sh

EXPOSE      5432/TCP
VOLUME      ["/var/lib/pgsql"]
CMD         ["/run.sh"]

HEALTHCHECK --interval=15s --timeout=3s --retries=3 CMD sudo -u postgres pg_ctl status -D /var/lib/postgresql/${DB_VER}/data || exit 1
