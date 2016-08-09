# Usage:
#
# docker build --force-rm -t zabbix-proxy .
# docker run -d --name zabbix-proxy -h zabbix-proxy zabbix-proxy
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
           SQLi_DB=/var/lib/sqlite/zabbix.db \
           SQLi_USER=zabbix

RUN        echo "http://dl-4.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
           && echo "http://dl-4.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
           && echo "http://dl-4.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
           && apk add --no-cache tzdata net-snmp-dev net-snmp-libs net-snmp net-snmp-perl net-snmp-tools fping sudo \
              zabbix zabbix-sqlite zabbix-agent zabbix-utils \
           && rm -f /etc/localtime && ln -s /usr/share/zoneinfo/UTC /etc/localtime \
           && apk del tzdata && rm -rf /var/cache/apk/*

ADD        files/*.sh /
RUN        chmod 755 /*.sh

# * Agent: 10050
# * Server: 10051
# * JavaGateway: 10052
EXPOSE     10050 10051 10052
VOLUME     ["/var/lib/sqlite", "/usr/lib/zabbix/alertscripts", "/usr/lib/zabbix/externalscripts", "/etc/zabbix/zabbix_agentd.d"]
CMD        ["/run.sh"]

HEALTHCHECK --interval=15s --timeout=3s --retries=3 CMD nc -vz localhost 10051 || exit 1

