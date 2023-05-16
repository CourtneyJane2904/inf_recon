#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/pentesting-ntp
host=$1
port=123
dest_dir="svc_scan_results/${host}/ntp"
mkdir -p "${dest_dir}"

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching NTP scans on ${host}:${port}"
# must download
nmap -sU -sV --script "ntp* and (discovery or vuln) and not (dos or brute)" -p "${port}" "${host}" -oA "${dest_dir}/general_p${port}" &
echo "NTP scans on ${host}:${port} launched."
exit 0
