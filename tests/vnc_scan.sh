#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/pentesting-vnc
host=$1
port=5001
dest_dir="svc_scan_results/${host}/vnc"
mkdir -p "${dest_dir}"

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching VNC scans on ${host}:${port}"

nmap -Pn -p"${port}" -sV --script vnc-info,vnc-title "${host}" -oA "${dest_dir}/general_p${port}" &
nmap -Pn -p"${port}" -sV --script realvnc-auth-bypass "${host}" -oA "${dest_dir}/realvnc_auth_bypass_p${port}" &
nmap -Pn -p"${port}" -sV --script vnc-brute "${host}" -oA "${dest_dir}/brute_p${port}" &
msfconsole -q -x "spool ${dest_dir}/vnc_brute_msf_p${port};use auxiliary/scanner/vnc/vnc_login;set RHOSTS ${host};set RPORT ${port};exploit;exit" 
msfconsole -q -x "spool ${dest_dir}/vnc_none_auth_msf_p${port};use auxiliary/scanner/vnc/vnc_none_auth;set RHOSTS ${host};set RPORT ${port};exploit;exit"

echo "VNC scans on ${host}:${port} launched."
exit 0

# connect: vncviewer [-passwd passwd.txt] <IP>::5901