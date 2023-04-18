#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/10000-network-data-management-protocol-ndmp
host=$1
port=10000
mkdir -R "test_results/ndmp/${host}"

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching NDMP scans on ${host}:${port}"
nmap -sCV -p "${port}" "${host}" -oA "test_results/ndmp/${host}/general_p${port}" &
echo "NDMP scans on ${host}:${port} launched."
exit 0

# snmp-check "${host}" -c public
# snmp-check "${host}" -c public -w