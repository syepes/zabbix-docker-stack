# Usage:
#
# https://wiki.alpinelinux.org/wiki/Setting_up_Zabbix
# docker build --force-rm -t zabbix-web .
# docker run -d --name zabbix-web -h zabbix-web -p 80:80 zabbix-web
#
FROM       alpine:latest
MAINTAINER Sebastian YEPES <syepes@gmail.com>

ARG        APK_FLAGS_COMMON="-q"
ARG        APK_FLAGS_PERSISTANT="${APK_FLAGS_COMMON} --clean-protected --no-cache"
ARG        APK_FLAGS_DEV="${APK_FLAGS_COMMON} --no-cache"
ARG        DB_TYPE=postgresql
ARG        ZBX_SOURCES="http://sourceforge.net/projects/zabbix/files/ZABBIX%20Latest%20Stable/3.2.1/zabbix-3.2.1.tar.gz/download"

ENV        LANG=en_US.UTF-8 \
           TERM=xterm \
           ZBX_SOURCES=${ZBX_SOURCES} \
           ZBX_SRV_HOST=172.17.0.1 \
           ZBX_SRV_PORT=10051 \
           ZBX_SRV_NAME= \
           DB_TYPE=${DB_TYPE} \
           PGSQL_HOST=172.17.0.1 \
           PGSQL_PORT=5432 \
           PGSQL_DB=zabbix \
           PGSQL_USER=zabbix \
           PGSQL_PASS=zabbix

RUN        echo "http://dl-4.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
           && echo "http://dl-4.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
           && echo "http://dl-4.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
           && apk update \
           && apk add ${APK_FLAGS_PERSISTANT} postgresql-client nginx php5-fpm php5-sockets php5-gd php5-gettext php5-bcmath php5-ctype php5-xmlreader php5-json php5-ldap php5-pgsql ttf-dejavu \
           && rm -rf /var/cache/apk/*

RUN        apk add ${APK_FLAGS_DEV} --virtual build-deps tzdata bash curl tar coreutils gettext \
           && rm -f /etc/localtime && ln -s /usr/share/zoneinfo/UTC /etc/localtime \
           && mkdir -p /tmp/zabbix \
           && curl -#SL "${ZBX_SOURCES}" | tar -xz -C /tmp/zabbix --strip-components 1 \
           && mkdir -p /usr/share/webapps/ \
           && cp -rp /tmp/zabbix/frontends/php /usr/share/webapps/zabbix \
           && /usr/share/webapps/zabbix/locale/make_mo.sh \
           && rm /usr/share/webapps/zabbix/fonts/DejaVuSans.ttf \
           && ln -s /usr/share/fonts/ttf-dejavu/DejaVuSans.ttf /usr/share/webapps/zabbix/fonts/DejaVuSans.ttf \
           && DATE=`date +%Y-%m-%d` \
           && sed -e "s/ZABBIX_VERSION.*'\(.*\)'/ZABBIX_VERSION', '\1 ($DATE)'/g" \
                  -e "s/ZABBIX_API_VERSION.*'\(.*\)'/ZABBIX_API_VERSION', '\1 ($DATE)'/g" -i /usr/share/webapps/zabbix/include/defines.inc.php \
           && sed -e "s/;\(pid =\).*/\1 \/var\/run\/php-fpm.pid/g" \
                  -e "s/;\(log_level =\).*/\1 warning/g" -i /etc/php5/php-fpm.conf \
           && cp /usr/share/webapps/zabbix/conf/zabbix.conf.php.example /usr/share/webapps/zabbix/conf/zabbix.conf.php \
           && apk del ${APK_FLAGS_COMMON} --purge build-deps \
           && rm -rf /var/cache/apk/* /tmp/zabbix/

ADD        files/nginx /
ADD        files/*.sh /
RUN        chmod 755 /*.sh

EXPOSE     80/TCP
CMD        ["/run.sh"]

HEALTHCHECK --interval=15s --timeout=3s --retries=3 CMD wget -U Docker-HealthCheck -Y off -O /dev/null http://localhost:80 || exit 1
