#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/pentesting-web
host=$1
port=80
mkdir -p "test_results/http/${host}"

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching HTTP scans on ${host}:${port}"

# enumeration with nmap
# run default nmap scripts for ftp and retrieve version
nc -v "${host}" "${port}" > "test_results/http/${host}/banner_p${port}" 
nmap -p${port} $host -sCV -oA "test_results/http/${host}/general_p${port}" &
whatweb -a 3 "http://${host}:${port}" > "test_results/http/${host}/whatweb_enum_p${port}" &
nikto -h "${ip}:${i}" -nointeractive -maxtime 360 >> "test_results/http/${host}/nikto_enum_p${port}" &
timeout 360 gobuster dir -r -u "http://${host}:${port}/" -w /usr/share/wordlists/dirb/common.txt -t 40 -x .js,.js.map,.txt > "test_results/http/${host}/pages_found_p${port}" &
echo "HTTP scans on ${host}:${port} launched."
exit 0