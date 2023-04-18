#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/pentesting-dns
host=$1
port=53
mkdir -R "test_results/domain/${host}"

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching DNS scans on ${host}:${port}"
# must download
nmap -n -sV --script "dns-nsid" ${host} -p"${port}" -oA "test_results/domain/${host}/banner_p${port}" &
nmap -n --script "(default and *dns*) or fcrdns or dns-srv-enum or dns-random-txid or dns-random-srcport" ${host} -p"${port}" -oA "test_results/domain/${host}/enum_p${port}" &
dig axfr @"${host}" > "test_results/domain/${host}/zone_transfer_p${port}" 
dig TXT @"${host}" > "test_results/domain/${host}/txt_records_p${port}"
dig MX@"${host}" > "test_results/domain/${host}/mail_records_p${port}"
dig google.com A @${host} > "test_results/domain/${host}/recursion_DDOS_p${port}"
echo "DNS scans on ${host}:${port} launched."
exit 0

# enum AD servers: nmap --script dns-srv-enum --script-args "dns-srv-enum.domain='domain.com'"