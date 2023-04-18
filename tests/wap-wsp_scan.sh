#!/bin/bash

# https://book.hacktricks.xyz/network-services-pentesting/9200-pentesting-elasticsearch
host=$1
port=9200
mkdir -R "test_results/wap-wsp/${host}"

if [[ ! -z "${2}" ]]; then
	port=$2
fi

echo "Launching elasticsearch scans on ${host}:${port}"
curl -X GET "${host}:${port}/" > "test_results/wap-wsp/general_p${port}"
curl -X GET "${host}:${port}/_xpack/security/user" > "test_results/wap-wsp/auth_info_p${port}"
echo "Elasticsearch scans on ${host}:${port} launched."
exit 0

# snmp-check "${host}" -c public
# snmp-check "${host}" -c public -w