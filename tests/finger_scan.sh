#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/pentesting-finger
host=$1
port=79
mkdir -p "test_results/finger/${host}"

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching finger scans on ${host}:${port}"
nc -vn "${host}" "${port}" > "test_results/finger/${host}/banner_p${port}" 
nmap -p${port} $host -sCV -oA "test_results/finger/${host}/general_p${port}" &
finger @{host} > "test_results/finger/${host}/user_list_p${port}"
echo "Finger scans on ${host}:${port} launched."
exit 0
