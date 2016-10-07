#!/bin/sh

sed -e "s/^\(Server=\).*/\1$ZBX_SRV_HOST/g" \
    -e "s/^\(ServerActive=\).*/\1$ZBX_SRV_HOST_ACT/g" \
    -e "s/.*\(StartAgents=\).*/\1$ZBX_AGT_NUM/g" \
    -e "s/.*\(ListenPort=\).*/\1$ZBX_AGT_PORT/g" \
    -e "s/^\(RefreshActiveChecks=\).*/\1$ZBX_AGT_RCHK_ACT/g" \
    -e "s/^\(Hostname=\).*/\1`hostname`/g" -i /etc/zabbix/zabbix_agentd.conf

echo "> Starting: Agent"
exec sudo -u zabbix /usr/sbin/zabbix_agentd -f -c /etc/zabbix/zabbix_agentd.conf
