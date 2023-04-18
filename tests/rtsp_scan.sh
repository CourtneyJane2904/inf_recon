#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/554-8554-pentesting-rtsp

host=$1
port=554
mkdir -p "test_results/rtsp/${host}"

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching RTSP scans on ${host}:${port}"
nmap -sV --script "rtsp-*" -p ${port} ${host} -oA "test_results/rtsp/${host}/general_p${port}" &
echo "RTSP scans on ${host}:${port} launched."
exit 0