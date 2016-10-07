# Usage:
#
# docker build --force-rm -t zabbix-proxy-db-pgsql .
# docker run -d --name zabbix-proxy -h zabbix-proxy zabbix-proxy-db-pgsql
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
            ZBX_PXY_MODE=0 \
            ZBX_SRV_HOST=172.17.0.1 \
            ZBX_SRV_HOST_ACT= \
            ZBX_SRV_PORT=10051 \
            ZBX_AGT_PORT=10050 \
            ZBX_NAME= \
            DB_TYPE=postgresql \
            DB_VER=9.6 \
            PG_INITDB_OPTS="-E UTF8 --locale='en_US.UTF-8'" \
            PGSQL_HOST=localhost \
            PGSQL_PORT=5432 \
            PGSQL_DB=proxy \
            PGSQL_USER=zabbix \
            PGSQL_PASS=zabbix

RUN         apk update \
            && apk add ${APK_FLAGS_PERSISTANT} bash sudo pwgen postgresql postgresql-client postgresql-libs fping libxml2 unixodbc net-snmp-agent-libs libldap libcurl openipmi-libs libssh2 \
            && addgroup zabbix \
            && adduser -S -D -G zabbix -h /var/lib/zabbix/ zabbix \
            && mkdir -p /etc/zabbix/zabbix_agentd.conf.d /etc/zabbix/zabbix_proxy.conf.d /var/log/zabbix /var/run/zabbix/ /var/lib/zabbix/enc /var/lib/zabbix/modules /var/lib/zabbix/externalscripts /var/lib/zabbix/alertscripts /var/lib/zabbix/mibs /var/lib/zabbix/snmptraps /var/lib/zabbix/ssh_keys /var/lib/zabbix/ssl/certs /var/lib/zabbix/ssl/keys /var/lib/zabbix/ssl/ssl_ca \
            && mkdir -p /usr/share/zabbix/database/${DB_TYPE}/ \
            && chown -R zabbix:root /var/lib/zabbix /var/run/zabbix /var/log/zabbix \
            && rm -rf /var/cache/apk/*

RUN         apk add ${APK_FLAGS_DEV} --virtual build-deps tzdata alpine-sdk coreutils automake autoconf postgresql-dev libxml2-dev unixodbc-dev net-snmp-dev libssh2-dev openipmi-dev openldap-dev curl-dev openssl-dev \
            && rm -f /etc/localtime && ln -s /usr/share/zoneinfo/UTC /etc/localtime \
            && cd /tmp/ \
            && mkdir -p /tmp/zabbix \
            && curl -#SL "${ZBX_SOURCES}" | tar -xz -C /tmp/zabbix --strip-components 1 \
            && cd /tmp/zabbix \
            && ./configure --prefix=/usr --silent --sysconfdir=/etc/zabbix --libdir=/usr/lib/zabbix \
                    --enable-proxy \
                    --enable-agent \
#                    --enable-static \
#                    --enable-ipv6 \
                    --with-ldap \
                    --with-net-snmp \
                    --with-openipmi \
                    --with-ssh2 \
                    --with-libcurl \
                    --with-unixodbc \
                    --with-libxml2 \
                    --with-openssl \
                    --with-${DB_TYPE} \
            && make -j"$(nproc)" -s 1>/dev/null \
            && cp src/zabbix_get/zabbix_get /usr/sbin/ \
            && cp src/zabbix_proxy/zabbix_proxy /usr/sbin/ \
            && cp conf/zabbix_proxy.conf /etc/zabbix/ \
            && cp src/zabbix_agent/zabbix_agentd /usr/sbin/ \
            && cp conf/zabbix_agentd.conf /etc/zabbix/ \
            && cp -r database/${DB_TYPE}/* /usr/share/zabbix/database/${DB_TYPE}/ \
            && chown -R zabbix:root /etc/zabbix \
            && sed -e "s/.*\(PidFile=\).*/\1\/var\/run\/zabbix\/zabbix_proxy.pid/g" \
                   -e "s/^\(LogFile=\).*/\1\/var\/log\/zabbix\/zabbix_proxy.log/g" \
                   -e "s/^#\(FpingLocation=.*\)/\1/g" \
                   -e "s/^# \(LoadModulePath=\)$/\1\/usr\/lib\/zabbix\/modules/g" \
                   -e "s/^# \(Include=\)$/\1\/etc\/zabbix\/zabbix_proxy.conf.d\/*\.conf/g" -i /etc/zabbix/zabbix_proxy.conf \
            && sed -e "s/.*\(PidFile=\).*/\1\/var\/run\/zabbix\/zabbix_agentd.pid/g" \
                   -e "s/^\(LogFile=\).*/\1\/var\/log\/zabbix\/zabbix_agentd.log/g" \
                   -e "s/^# \(LoadModulePath=\)$/\1\/usr\/lib\/zabbix\/modules/g" \
                   -e "s/^# \(Include=\)$/\1\/etc\/zabbix\/zabbix_agentd.conf.d\/*\.conf/g" -i /etc/zabbix/zabbix_agentd.conf \
            && chmod 4770 /usr/sbin/fping \
            && chmod ug+s /usr/sbin/fping \
            && chown root:zabbix /usr/sbin/fping \
            && apk del ${APK_FLAGS_COMMON} --purge build-deps \
            && rm -rf /var/cache/apk/* /tmp/zabbix/

ADD         files/*.sh /
RUN         chmod 755 /*.sh

EXPOSE      5432/TCP 10050/TCP 10051/TCP
VOLUME      ["/var/lib/pgsql", "/etc/zabbix/zabbix_agentd.d", "/usr/lib/zabbix/alertscripts", "/usr/lib/zabbix/externalscripts", "/usr/lib/zabbix/modules"]
CMD         ["/run.sh"]

HEALTHCHECK --interval=15s --timeout=3s --retries=3 CMD nc -vz localhost 10051 || exit 1

