#!/bin/sh
set -e

sed -e "s/.*\(PidFile=\).*/\1\/var\/run\/zabbix\/zabbix_proxy.pid/g" \
    -e "s/.*\(ProxyMode=\).*/\1$ZBX_PXY_MODE/g" \
    -e "s/^\(Server=\).*/\1$ZBX_SRV_HOST/g" \
    -e "s/.*\(ServerPort=\).*/\1$ZBX_SRV_PORT/g" \
    -e "s/^\(Hostname=\).*/\1`hostname`/g" \
    -e "s/^\(DBName=\).*/\1$(echo "$SQLi_DB" | sed 's/[\/&]/\\&/g')/g" \
    -e "s/^\(DBUser=\).*/\1$SQLi_USER/g" -i /etc/zabbix/zabbix_proxy.conf

sed -e "s/.*\(PidFile=\).*/\1\/var\/run\/zabbix\/zabbix_agentd.pid/g" \
    -e "s/^\(Server=\).*/\1$ZBX_SRV_HOST/g" \
    -e "s/^\(ServerActive=\).*/\1$ZBX_SRV_HOST_ACT/g" \
    -e "s/.*\(ListenPort=\).*/\1$ZBX_AGT_PORT/g" \
    -e "s/^\(Hostname=\).*/\1`hostname`/g" -i /etc/zabbix/zabbix_agentd.conf



echo "> Starting: Agent"
/usr/sbin/zabbix_agentd -c /etc/zabbix/zabbix_agentd.conf

echo "> Starting: Proxy"
chown zabbix:zabbix /var/lib/sqlite/
exec sudo -u zabbix /usr/sbin/zabbix_proxy -f -c /etc/zabbix/zabbix_proxy.conf
