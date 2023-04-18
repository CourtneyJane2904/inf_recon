#!/bin/bash

# https://medium.com/@netscylla/pentesters-guide-to-oracle-hacking-1dcf7068d573
# https://book.hacktricks.xyz/network-services-pentesting/1521-1522-1529-pentesting-oracle-listener
host=$1
port=1521
mkdir -R "test_results/oracle-tns/${host}"
oracle_creds="wordlists/oracle_default_creds.txt"
if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching Oracle scans on ${host}:${port}"
# must download
nmap --script "oracle-tns-version" -p ${port} -T4 -sV ${host} -oA "test_results/oracle-tns/${host}/general_p${port}" &
nmap --script +oracle-sid-brute -p ${port} ${host} -oA "test_results/oracle-tns/${host}/sid_brute_p${port}" &
oscanner -s "${host}" -P ${port} > "test_results/oracle-tns/${host}/oscanner_p${port}" &
echo "Oracle scans on ${host}:${port} launched."
exit 0

# get general info on oracle: ./tnscmd.pl status -h 192.168.0.2
# brute force listener pass (needed if above tnscmd fails): ./hydra -P rockyou.txt -t 32 -s 1521 host.victim oracle-listener
# brute force sid alt way: ./hydra -L /usr/share/oscanner/lib/services.txt -s 1521 host.victim oracle-sid
# brute force credentials alt way: hydra -C /tmp/creds.txt -s 1521 host.victim oracle /PLSEXTPROC