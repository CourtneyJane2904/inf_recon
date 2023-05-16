#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/pentesting-telnet
host=$1
port=23
dest_dir="svc_scan_results/${host}/telnet"
mkdir -p "${dest_dir}"

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching Telnet scans on ${host}:${port}"

nc -vn "${host}" "${port}" > "${dest_dir}/banner_p${port}" 
nmap -p${port} $host -sCV -oA "${dest_dir}/general_p${port}" &
nmap -n -sV -Pn --script "*telnet* and safe" -p "${port}" "${host}" -oA "${dest_dir}/nmap-scripts_p${port}" &

echo "Telnet scans on ${host}:${port} launched."
exit 0