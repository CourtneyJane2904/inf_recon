#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/9200-pentesting-elasticsearch
host=$1
port=9200
dest_dir="svc_scan_results/${host}/wap-wsp"
mkdir -p "${dest_dir}"

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching elasticsearch scans on ${host}:${port}"
curl -X GET "${host}:${port}/" > "${dest_dir}/general_p${port}"
curl -X GET "${host}:${port}/_xpack/security/user" > "${dest_dir}/auth_info_p${port}"
echo "Elasticsearch scans on ${host}:${port} launched."
exit 0