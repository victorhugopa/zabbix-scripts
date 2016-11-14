# zabbix-scripts
Scripts to automate tasks in Zabbix

#### hostname_from_snmp.sh:
Simple script to rename hosts into Zabbix3/MySQL by data from SNMP sysName.

Usage: 
```
./hostname_from_snmp.sh v2c 192.168.1.1
./hostname_from_snmp.sh v3 192.168.1.% (SQL wildcard)
```
Based on http://developers-club.com/posts/82465/ (simpler Zabbix 1.8 version)
