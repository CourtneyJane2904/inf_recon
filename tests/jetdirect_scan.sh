#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/9100-pjl
host=$1
port=9100
mkdir -p "test_results/jetdirect/${host}"

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching raw printing scans on ${host}:${port}"
# must download
nmap -p${port} --script pjl-ready-message "${host}" -oA "test_results/jetdirect/${host}/pjl-ready_p${port}" &
echo "Raw printing scans on ${host}:${port} launched."
exit 0