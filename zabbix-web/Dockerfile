# Usage:
#
# https://wiki.alpinelinux.org/wiki/Setting_up_Zabbix
# docker build --force-rm -t zabbix-web .
# docker run -d --name zabbix-web -h zabbix-web -p 80:80 zabbix-web
#
FROM       alpine:latest
MAINTAINER Sebastian YEPES <syepes@gmail.com>


ENV        LANG=en_US.UTF-8 \
           ZBX_SRV_HOST=172.17.0.1 \
           ZBX_SRV_PORT=10051 \
           ZBX_SRV_NAME= \
           PGSQL_HOST=172.17.0.1 \
           PGSQL_PORT=5432 \
           PGSQL_DB=zabbix \
           PGSQL_USER=zabbix \
           PGSQL_PASS=zabbix

RUN        echo "http://dl-4.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
           && echo "http://dl-4.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
           && echo "http://dl-4.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
           && apk add --no-cache tzdata postgresql-client postgresql-libs \
               openssl nginx php php5-fpm php5-gd php5-gettext php5-bcmath php5-ctype php5-pgsql \
               zabbix-pgsql zabbix-webif \
           && rm -f /etc/localtime && ln -s /usr/share/zoneinfo/UTC /etc/localtime \
           && DATE=`date +%Y-%m-%d` \
           && sed -e "s/ZABBIX_VERSION.*'\(.*\)'/ZABBIX_VERSION', '\1 ($DATE)'/g" \
                  -e "s/ZABBIX_API_VERSION.*'\(.*\)'/ZABBIX_API_VERSION', '\1 ($DATE)'/g" -i /usr/share/webapps/zabbix/include/defines.inc.php \
           && sed -e "s/;\(pid =\).*/\1 \/var\/run\/php-fpm.pid/g" \
                  -e "s/;\(log_level =\).*/\1 warning/g" -i /etc/php5/php-fpm.conf \
           && cp /usr/share/webapps/zabbix/conf/zabbix.conf.php.example /usr/share/webapps/zabbix/conf/zabbix.conf.php \
           && apk del tzdata && rm -rf /var/cache/apk/*

ADD        files/nginx /
ADD        files/*.sh /
RUN        chmod 755 /*.sh

# * Zabbix UI
EXPOSE     80
VOLUME     ["/data"]
CMD        ["/run.sh"]

HEALTHCHECK --interval=15s --timeout=3s --retries=3 CMD wget -U Docker-HealthCheck -Y off -O /dev/null http://localhost:80 || exit 1

