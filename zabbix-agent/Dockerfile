# Usage:
#
# docker build --force-rm -t zabbix-agent .
# docker run -d --name zabbix-agent1 -h zabbix-agent1 -p 10050:10050 zabbix-agent
# docker run -d --name zabbix-agent2 -h zabbix-agent2 -p 10052:10050 zabbix-agent
# docker run -d --name zabbix-agent2 -h zabbix-agent2 -e ZBX_SRV_HOST= -e ZBX_AGT_NUM=0 -e ZBX_SRV_HOST_ACT=172.17.0.7 zabbix-agent
# docker run -d --name zabbix-agent2 -h zabbix-agent2 -e ZBX_SRV_HOST=172.17.0.7 zabbix-agent
#
FROM       alpine:latest
MAINTAINER Sebastian YEPES <syepes@gmail.com>


ENV        LANG=en_US.UTF-8 \
           ZBX_SRV_HOST=127.0.0.1,172.17.0.1 \
           ZBX_SRV_HOST_ACT= \
           ZBX_AGT_NUM=3 \
           ZBX_AGT_PORT=10050 \
           ZBX_AGT_RCHK_ACT=120

RUN        echo "http://dl-4.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
           && echo "http://dl-4.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
           && echo "http://dl-4.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
           && apk add --no-cache tzdata sudo zabbix zabbix-agent zabbix-utils \
           && rm -f /etc/localtime && ln -s /usr/share/zoneinfo/UTC /etc/localtime \
           && apk del tzdata && rm -rf /var/cache/apk/*

ADD        files/*.sh /
RUN        chmod 755 /*.sh

# Expose the Ports used by
# * Agent: 10050 Only if ZBX_AGT_NUM >0
EXPOSE     10050
VOLUME     ["/usr/lib/zabbix/alertscripts", "/usr/lib/zabbix/externalscripts", "/etc/zabbix/zabbix_agentd.d"]
CMD        ["/run.sh"]

HEALTHCHECK --interval=15s --timeout=3s --retries=3 CMD ps -o pid |egrep "^\s+$(cat /var/run/zabbix/zabbix_agentd.pid)\$" 1>/dev/null || exit 1

