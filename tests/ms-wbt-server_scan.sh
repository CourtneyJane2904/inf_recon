#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/pentesting-rdp
host=$1
port=3389
dest_dir="svc_scan_results/${host}/ms-wbt-server"
mkdir -p "${dest_dir}"

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching RDP scans on ${host}:${port}"

# enumeration with nmap
# run default nmap scripts for ftp and retrieve version
nmap -Pn -p${port} $host -sCV -oA "${dest_dir}/general_p${port}" &
nmap -Pn --script "rdp-vuln*" -p ${port} -T4 ${host} -oA "${dest_dir}/vulns_p${port}" &
nmap -Pn --script "rdp-ntlm-info" -p ${port} -T4 ${host} -oA "${dest_dir}/ntlm_p${port}" &
nmap -Pn --script "rdp-enum-encryption" -p ${port} -T4 ${host} -oA "${dest_dir}/encryption_p${port}" &

echo "RDP scans on ${host}:${port} launched."
exit 0

# rdesktop -u <username> <IP>
# rdesktop -d <domain> -u <username> -p <password> <IP>
# xfreerdp [/d:domain] /u:<username> /p:<password> /v:<IP>
# xfreerdp [/d:domain] /u:<username> /pth:<hash> /v:<IP>