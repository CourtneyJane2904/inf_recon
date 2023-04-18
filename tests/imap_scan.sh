#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/pentesting-imap
host=$1
port=143
mkdir -R "test_results/imap/${host}"

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching IMAP scans on ${host}:${port}"
# must download
nc -nv "${host}" "${port}" > "test_results/imap/${host}/banner_p${port}"
nmap -sV --script "imap-ntlm-info" -p ${port} ${host} -oA "test_results/imap/${host}/ntlm_info_p${port}" &
echo "IMAP scans on ${host}:${port} launched."
exit 0