#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/69-udp-tftp
host=$1
port=69
mkdir -p "test_results/tftp/${host}"

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching TFTP scans on ${host}:${port}"

nmap -n -Pn -sU -p"${port}" -sV --script tftp-enum "${host}" -oA "test_results/tftp/${host}/tftp_enum_p${port}" &

echo "TFTP scans on ${host}:${port} launched."
exit 0