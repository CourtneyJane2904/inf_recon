#!/bin/bash

filename=$1

for host_file in $(find analysis/tcp_host_lists_by_svc -name *_hosts.txt); do
	svc=$(echo ${host_file} | cut -d '/' -f3 | cut -d '_' -f1)
	
	if [[ ! -z $(echo "${svc}" | grep "netbios") ]]; then tests/netbios_scan.sh "${filename}" & fi
	
	while read l; do
		ip=$(echo "${l}" | cut -d ':' -f1)
		port=$(echo "${l}" | cut -d ':' -f2)
		echo "Launching ${svc} scans on ${ip}"
		"tests/${svc}_scan.sh" "${ip}" "${port}" &
	done < "${host_file}"
done
echo "TCP analysis complete."
stty echo
exit 0