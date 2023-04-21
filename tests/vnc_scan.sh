#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/pentesting-vnc
host=$1
port=5001
mkdir -p "test_results/vnc/${host}"

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching VNC scans on ${host}:${port}"

nmap -n -Pn -p"${port}" -sV --script vnc-info,vnc-title "${host}" -oA "test_results/vnc/${host}/general_p${port}" &
nmap -n -Pn -p"${port}" -sV --script realvnc-auth-bypass "${host}" -oA "test_results/vnc/${host}/realvnc_auth_bypass_p${port}" &
nmap -n -Pn -p"${port}" -sV --script vnc-brute "${host}" -oA "test_results/vnc/${host}/brute_p${port}" &

echo "VNC scans on ${host}:${port} launched."
exit 0

# connect: vncviewer [-passwd passwd.txt] <IP>::5901