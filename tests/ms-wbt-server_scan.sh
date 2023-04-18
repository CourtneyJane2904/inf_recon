#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/pentesting-rdp
host=$1
port=3389
mkdir -p "test_results/ms-wbt-server/${host}"

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching RDP scans on ${host}:${port}"

# enumeration with nmap
# run default nmap scripts for ftp and retrieve version
nmap -p${port} $host -sCV -oA "test_results/ms-wbt-server/${host}/general_p${port}" &
nmap --script "rdp-vuln-ms12-020" -p ${port} -T4 ${host} -oA "test_results/ms-wbt-server/${host}/vuln_p${port}" &
nmap --script "rdp-ntlm-info" -p ${port} -T4 ${host} -oA "test_results/ms-wbt-server/${host}/ntlm_p${port}" &
nmap --script "rdp-enum-encryption" -p ${port} -T4 ${host} -oA "test_results/ms-wbt-server/${host}/encryption_p${port}" &

echo "RDP scans on ${host}:${port} launched."
exit 0

# rdesktop -u <username> <IP>
# rdesktop -d <domain> -u <username> -p <password> <IP>
# xfreerdp [/d:domain] /u:<username> /p:<password> /v:<IP>
# xfreerdp [/d:domain] /u:<username> /pth:<hash> /v:<IP>