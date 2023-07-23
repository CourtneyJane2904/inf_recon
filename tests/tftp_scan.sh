#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/69-udp-tftp
host=$1
port=69
dest_dir="svc_scan_results/${host}/tftp"
mkdir -p "${dest_dir}"

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching TFTP scans on ${host}:${port}"

nmap -Pn -sU -p"${port}" -sV --script tftp-enum "${host}" -oA "${dest_dir}/tftp_enum_p${port}" &
msfconsole -q -x "spool ${dest_dir}/tftp_brute_msf_p${port};use auxiliary/scanner/tftp/tftpbrute;set RHOSTS ${host};exploit;exit"
echo "TFTP scans on ${host}:${port} launched."
exit 0
