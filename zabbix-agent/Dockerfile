# Usage:
#
# docker build --force-rm -t zabbix-agent .
# docker run -d --name zabbix-agent1 -h zabbix-agent1 -p 10050:10050 zabbix-agent
# docker run -d --name zabbix-agent2 -h zabbix-agent2 -p 10052:10050 zabbix-agent
# docker run -d --name zabbix-agent2 -h zabbix-agent2 -e ZBX_SRV_HOST= -e ZBX_AGT_NUM=0 -e ZBX_SRV_HOST_ACT=172.17.0.7 zabbix-agent
# docker run -d --name zabbix-agent2 -h zabbix-agent2 -e ZBX_SRV_HOST=172.17.0.7 zabbix-agent
#
FROM        alpine:latest
MAINTAINER  Sebastian YEPES <syepes@gmail.com>

ARG         APK_FLAGS_COMMON="-q"
ARG         APK_FLAGS_PERSISTANT="${APK_FLAGS_COMMON} --clean-protected --no-cache"
ARG         APK_FLAGS_DEV="${APK_FLAGS_COMMON} --no-cache"
ARG         ZBX_SOURCES="http://sourceforge.net/projects/zabbix/files/ZABBIX%20Latest%20Stable/3.2.1/zabbix-3.2.1.tar.gz/download"

ENV         LANG=en_US.UTF-8 \
            TERM=xterm \
            ZBX_SOURCES=${ZBX_SOURCES} \
            ZBX_SRV_HOST=127.0.0.1,172.17.0.1 \
            ZBX_SRV_HOST_ACT= \
            ZBX_AGT_NUM=3 \
            ZBX_AGT_PORT=10050 \
            ZBX_AGT_RCHK_ACT=120 \
            MIBDIRS=/var/lib/zabbix/mibs \
            MIBS=+ALL

RUN         apk update \
            && addgroup zabbix \
            && adduser -S -D -G zabbix -h /var/lib/zabbix/ zabbix \
            && mkdir -p /etc/zabbix/zabbix_agentd.conf.d /var/log/zabbix /var/run/zabbix/ /var/lib/zabbix/enc /var/lib/zabbix/modules /var/lib/zabbix/externalscripts /var/lib/zabbix/alertscripts /var/lib/zabbix/mibs /var/lib/zabbix/snmptraps /var/lib/zabbix/ssh_keys /var/lib/zabbix/ssl/certs /var/lib/zabbix/ssl/keys /var/lib/zabbix/ssl/ssl_ca \
            && chown -R zabbix:root /var/lib/zabbix /var/run/zabbix /var/log/zabbix \
            && rm -rf /var/cache/apk/*

RUN         apk add ${APK_FLAGS_DEV} --virtual build-deps tzdata alpine-sdk coreutils automake autoconf libxml2-dev net-snmp-dev libssh2-dev openipmi-dev openssl-dev \
            && apk add ${APK_FLAGS_DEV} sudo curl-dev \
            && rm -f /etc/localtime && ln -s /usr/share/zoneinfo/UTC /etc/localtime \
            && mkdir -p /tmp/zabbix \
            && curl -#SL "${ZBX_SOURCES}" | tar -xz -C /tmp/zabbix --strip-components 1 \
            && cd /tmp/zabbix \
            && ./configure --prefix=/usr --silent --sysconfdir=/etc/zabbix --libdir=/usr/lib/zabbix \
                    --enable-agent \
#                    --enable-static \
#                    --enable-ipv6 \
                    --with-net-snmp \
                    --with-openipmi \
                    --with-ssh2 \
                    --with-libcurl \
                    --with-libxml2 \
                    --with-openssl \
            && make -j"$(nproc)" -s 1>/dev/null \
            && cp src/zabbix_agent/zabbix_agentd /usr/sbin/ \
            && cp conf/zabbix_agentd.conf /etc/zabbix/ \
            && chown -R zabbix:root /etc/zabbix \
            && sed -e "s/.*\(PidFile=\).*/\1\/var\/run\/zabbix\/zabbix_agentd.pid/g" \
                   -e "s/^\(LogFile=\).*/\1\/var\/log\/zabbix\/zabbix_agentd.log/g" \
                   -e "s/^# \(LoadModulePath=\)$/\1\/usr\/lib\/zabbix\/modules/g" \
                   -e "s/^# \(Include=\)$/\1\/etc\/zabbix\/zabbix_agentd.conf.d\/*\.conf/g" -i /etc/zabbix/zabbix_agentd.conf \
            && apk del ${APK_FLAGS_COMMON} --purge build-deps \
            && rm -rf /var/cache/apk/* /tmp/zabbix/

ADD         files/*.sh /
RUN         chmod 755 /*.sh

EXPOSE      10050/TCP
VOLUME      ["/etc/zabbix/zabbix_agentd.conf.d", "/usr/lib/zabbix/alertscripts", "/usr/lib/zabbix/externalscripts", "/usr/lib/zabbix/modules"]
CMD         ["/run.sh"]

HEALTHCHECK --interval=15s --timeout=3s --retries=3 CMD ps -o pid |egrep "^\s+$(cat /var/run/zabbix/zabbix_agentd.pid)\$" 1>/dev/null || exit 1
