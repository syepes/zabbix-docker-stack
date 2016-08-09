#!/bin/sh

__stop() {
 echo "> SIGTERM signal received, try to gracefully shutdown all services..."
 echo "> Stopping: Agent"
 kill $(cat /var/run/zabbix/zabbix_agentd.pid)
 tail -n50 /var/log/zabbix/zabbix_agentd.log
 echo "> Stopping: Server"
 kill $(cat /var/run/zabbix/zabbix_server.pid)
 tail -n50 /var/log/zabbix/zabbix_server.log
}

trap "__stop; exit 0" SIGTERM SIGINT

sed -e "s/.*\(PidFile=\).*/\1\/var\/run\/zabbix\/zabbix_server.pid/g" \
    -e "s/.*\(ListenPort=\).*/\1$ZBX_SRV_PORT/g" \
    -e "s/.*\(DBHost=\).*/\1$PGSQL_HOST/g" \
    -e "s/^\(DBName=\).*/\1$PGSQL_DB/g" \
    -e "s/.*\(DBPort=\).*/\1$PGSQL_PORT/g" \
    -e "s/^\(DBUser=\).*/\1$PGSQL_USER/g" \
    -e "s/.*\(DBPassword=\).*/\1$PGSQL_PASS/g" -i /etc/zabbix/zabbix_server.conf

sed -e "s/.*\(PidFile=\).*/\1\/var\/run\/zabbix\/zabbix_agentd.pid/g" \
    -e "s/^\(Server=\).*/\1$ZBX_SRV_HOST/g" \
    -e "s/^\(ServerActive=\).*/\1$ZBX_SRV_HOST_ACT/g" \
    -e "s/.*\(StartAgents=\).*/\1$ZBX_AGT_NUM/g" \
    -e "s/.*\(ListenPort=\).*/\1$ZBX_AGT_PORT/g" \
    -e "s/^\(Hostname=\).*/\1`hostname`/g" -i /etc/zabbix/zabbix_agentd.conf

echo "> Starting: Server"
/usr/sbin/zabbix_server -c /etc/zabbix/zabbix_server.conf
tail -n100 /var/log/zabbix/zabbix_server.log

echo "> Starting: Agent"
/usr/sbin/zabbix_agentd -c /etc/zabbix/zabbix_agentd.conf
tail -n100 /var/log/zabbix/zabbix_agentd.log

while true; do
 sleep 15s & wait $!;
 ps -o pid |egrep "^\s+$(cat /var/run/zabbix/zabbix_server.pid)\$" 1>/dev/null || exit 1;
done

