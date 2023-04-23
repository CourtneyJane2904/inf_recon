#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/pentesting-web
host=$1
port=443
mkdir -p "test_results/https/${host}"
testssl=$(locate testssl.sh | head -n 1)

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching HTTPS scans on ${host}:${port}"

# enumeration with nmap
openssl s_client -connect ${host}:${port} -crlf -quiet > "test_results/https/${host}/banner_p${port}"
# run default nmap scripts for ftp and retrieve version
nmap -p${port} $host -sCV -oA "test_results/https/${host}/general_p${port}" &
"${testssl}" "https://${host}:${port}" > "test_results/https/${host}/ssl_issues_p${port}" &
whatweb -a 3 "https://${host}:${port}" > "test_results/https/${host}/whatweb_enum_p${port}" &
nikto -h "${host}:${port}" -nointeractive -maxtime 360 >> "test_results/http/${host}/nikto_enum_p${port}" &
timeout 360 gobuster dir -r -u "https://${host}:${port}/" -w wordlists/small_dir_list.txt -t 40 -x .js,.js.map,.txt > "test_results/http/${host}/pages_found_p${port}" &
echo "HTTPS scans on ${host}:${port} launched."
exit 0
