#!/bin/bash

filename=$1
MAX_CONCURRENT=5  # Set your safe limit here
current_jobs=0

for host_file in $(find analysis/tcp_host_lists_by_svc -name *_hosts.txt); do
    svc=$(echo ${host_file} | cut -d '/' -f3 | cut -d '_' -f1)

    if [[ ! -z $(echo "${svc}" | grep "netbios") ]]; then
        tests/netbios_scan.sh "${filename}" &
        ((current_jobs++))
    fi

    while read l; do
        ip=$(echo "${l}" | cut -d ':' -f1)
        port=$(echo "${l}" | cut -d ':' -f2)
        echo "Launching ${svc} scans on ${ip}"
        "tests/${svc}_scan.sh" "${ip}" "${port}" &
		if [[ ! -d "svc_scan_results/${ip}/nuclei" ]]; then "tests/nuclei.sh" & fi
        ((current_jobs++))

        # Check if we hit the limit, wait if so
	while (( $(jobs -r | wc -l) >= MAX_CONCURRENT )); do
		sleep 1
	done
    done < "${host_file}"
done

# Wait for all remaining background jobs
wait
echo "TCP analysis complete."
stty echo
exit 0
