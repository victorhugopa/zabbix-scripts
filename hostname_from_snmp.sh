#!/bin/bash
#Automatic renaming of hosts into Zabbix by data from snmp sysName
#Tested on: Zabbix 3/MariaDB
#Based on:  http://developers-club.com/posts/82465/ (Zabbix 1.8 version)
#Feature request: https://support.zabbix.com/browse/ZBXNEXT-158
#Usage: ./hostname_snmp.sh {v2c|v3} 192.168.1.%
#victorhugopa.tumblr.com | github.com/victorhugopa

db_name=zabbix
db_host=127.0.0.1
db_user=zabbix
db_pass=
#SNMPv2c
community=comm
#SNMPv3
securityName=
authProtocol=SHA
privProtocol=AES
authKey=
privKey=
securityLevel=authPriv
IP=$2
MYSQL="mysql --connect-timeout=10 $db_name --host=$db_host --user=$db_user --password=$db_pass --skip-column-names -B -e"

set_v2c() {
$MYSQL "SELECT ip FROM interface where ip like '$IP'" | while read line
do
        arr=($line)
        v2c=`snmpget -Oqv -v2c -c $community ${arr[0]} system.sysName.0 2> /dev/null | tr " " "-"`
        [[ -n $v2c ]] &&$MYSQL "UPDATE hosts h INNER JOIN interface i ON i.hostid = h.hostid SET h.host='$v2c',h.name='$v2c' WHERE i.ip ='${arr[0]}'"
		echo ${arr[0]} updated: $v2c
done
}

set_v3() {
$MYSQL "SELECT ip FROM interface where ip like '$IP'" | while read line
do
        arr=($line)
        v3=`snmpget -Oqv -v3 -l $securityLevel -a $authProtocol -u $securityName -A $authKey -x $privProtocol -X $privKey ${arr[0]} system.sysName.0 2> /dev/null | tr " " "-"`
        [[ -n $v3 ]] &&$MYSQL "UPDATE hosts h INNER JOIN interface i ON i.hostid = h.hostid SET h.host='$v3',h.name='$v3' WHERE i.ip ='${arr[0]}'"
		 echo ${arr[0]} updated: $v3
done
}

case "$1" in
        v2c)
            set_v2c
            ;;
        v3)
            set_v3
            ;;
        *)
            echo $"Usage: $0 {v2c|v3} IP"
                        echo $"Example: $0 v2c 192.168.1.1"
                        echo $"Example (SQL wildcard): $0 v3 192.168.1.%"
                        exit 1
esac
