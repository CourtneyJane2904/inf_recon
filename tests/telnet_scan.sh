#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/pentesting-telnet
host=$1
port=23
mkdir -p "test_results/telnet/${host}"

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching Telnet scans on ${host}:${port}"

nc -vn "${host}" "${port}" > "test_results/telnet/${host}/banner_p${port}" 
nmap -p${port} $host -sCV -oA "test_results/telnet/${host}/general_p${port}" &
nmap -n -sV -Pn --script "*telnet* and safe" -p "${port}" "${host}" -oA "test_results/telnet/${host}/nmap-scripts_p${port}" &

echo "Telnet scans on ${host}:${port} launched."
exit 0