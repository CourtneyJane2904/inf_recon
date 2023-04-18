#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/pentesting-snmp
# https://book.hacktricks.xyz/network-services-pentesting/pentesting-snmp/snmp-rce
host=$1
port=161
mkdir -R "test_results/snmp/${host}"
# https://github.com/danielmiessler/SecLists/blob/master/Passwords/Default-Credentials/ftp-betterdefaultpasslist.txt
snmp_comm_strs="$( locate common-snmp-community-strings.txt | head -n 1 )"
if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching SNMP scans on ${host}:${port}"
# must download
nmap -sU --script snmp-brute "${host}" -p${port} -oA "test_results/snmp/${host}/snmp_brute_p${port}" &
hydra -P "${snmp_comm_strs}" "${host}" -s "${port}" -o "test_results/snmp/${host}/hydra_brute_p${port}" snmp &
echo "SNMP scans on ${host}:${port} launched."
exit 0

# access data: snmp-check "${host}" -c public
# check if we have write access: snmp-check "${host}" -c public -w