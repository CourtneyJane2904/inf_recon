#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/pentesting-web
host=$1
port=80
dest_dir="svc_scan_results/${host}/http"
mkdir -p "${dest_dir}"

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching HTTP scans on ${host}:${port}"

# enumeration with nmap
# run default nmap scripts for ftp and retrieve version
nc -v "${host}" "${port}" > "${dest_dir}/banner_p${port}" 
nmap -Pn -p${port} $host -sCV -oA "${dest_dir}/general_p${port}" &
whatweb -a 3 "http://${host}:${port}" > "${dest_dir}/whatweb_enum_p${port}" &
nikto -h "http://${host}:${port}/" -nointeractive -maxtime 360 >> "${dest_dir}/nikto_enum_p${port}" &
timeout 360 gobuster -r -u "http://${host}:${port}/" -w wordlists/small_dir_list.txt -t 40 -x .js,.js.map,.txt > "${dest_dir}/pages_found_p${port}" &
echo "HTTP scans on ${host}:${port} launched."
exit 0
