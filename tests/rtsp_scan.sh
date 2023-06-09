#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/554-8554-pentesting-rtsp

host=$1
port=554
dest_dir="svc_scan_results/${host}/rtsp"
mkdir -p "${dest_dir}"

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching RTSP scans on ${host}:${port}"
nmap -Pn -sV --script "rtsp-*" -p ${port} ${host} -oA "${dest_dir}/general_p${port}" &
echo "RTSP scans on ${host}:${port} launched."
exit 0