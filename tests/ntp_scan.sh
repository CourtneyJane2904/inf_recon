#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/pentesting-ntp
host=$1
port=123
mkdir -p "test_results/ntp/${host}"

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching NTP scans on ${host}:${port}"
# must download
nmap -sU -sV --script "ntp* and (discovery or vuln) and not (dos or brute)" -p "${port}" "${host}" -oA "test_results/ntp/${host}/general_p${port}" &
echo "NTP scans on ${host}:${port} launched."
exit 0
