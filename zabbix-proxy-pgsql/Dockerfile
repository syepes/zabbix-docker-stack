# Usage:
#
# docker build --force-rm -t zabbix-proxy-db .
# docker run -d --name zabbix-proxy-db -h zabbix-proxy-db zabbix-proxy-db
#
FROM       alpine:latest
MAINTAINER Sebastian YEPES <syepes@gmail.com>


ENV        LANG=en_US.UTF-8 \
           ZBX_PXY_MODE=0 \
           ZBX_SRV_HOST=172.17.0.1 \
           ZBX_SRV_HOST_ACT= \
           ZBX_SRV_PORT=10051 \
           ZBX_AGT_PORT=10050 \
           ZBX_NAME= \
           PG_INITDB_OPTS="-E UTF8 --locale='en_US.UTF-8'" \
           PGSQL_HOST=localhost \
           PGSQL_PORT=5432 \
           PGSQL_DB=proxy \
           PGSQL_USER=zabbix \
           PGSQL_PASS=zabbix

RUN        echo "http://dl-4.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
           && echo "http://dl-4.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
           && echo "http://dl-4.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
           && apk add --no-cache tzdata net-snmp-dev net-snmp-libs net-snmp net-snmp-perl net-snmp-tools fping sudo pwgen postgresql postgresql-client postgresql-libs \
              zabbix zabbix-pgsql zabbix-setup zabbix-agent zabbix-utils \
           && rm -f /etc/localtime && ln -s /usr/share/zoneinfo/UTC /etc/localtime \
           && apk del tzdata && rm -rf /var/cache/apk/*

ADD        files/*.sh /
RUN        chmod 755 /*.sh

# * Postgresql: 5432
# * Agent: 10050
# * Server: 10051
# * JavaGateway: 10052
EXPOSE     5432 10050 10051 10052
VOLUME     ["/var/lib/pgsql", "/usr/lib/zabbix/alertscripts", "/usr/lib/zabbix/externalscripts", "/etc/zabbix/zabbix_agentd.d"]
CMD        ["/run.sh"]

HEALTHCHECK --interval=15s --timeout=3s --retries=3 CMD nc -vz localhost 10051 || exit 1

