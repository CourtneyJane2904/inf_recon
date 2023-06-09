#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/pentesting-dns
host=$1
port=53
dest_dir="svc_scan_results/${host}/domain"
mkdir -p "${dest_dir}"

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching DNS scans on ${host}:${port}"
# must download
nmap -Pn -sV --script "dns-nsid" ${host} -p"${port}" -oA "${dest_dir}/banner_p${port}" &
nmap -Pn --script "(default and *dns*) or fcrdns or dns-srv-enum or dns-random-txid or dns-random-srcport" ${host} -p"${port}" -oA "${dest_dir}/enum_p${port}" &
dig axfr @"${host}" > "${dest_dir}/zone_transfer_p${port}" 
dig TXT @"${host}" > "${dest_dir}/txt_records_p${port}"
dig MX@"${host}" > "${dest_dir}/mail_records_p${port}"
dig google.com A @${host} > "${dest_dir}/recursion_DDOS_p${port}"
echo "DNS scans on ${host}:${port} launched."
exit 0

# enum AD servers: nmap --script dns-srv-enum --script-args "dns-srv-enum.domain='domain.com'"