#!/bin/bash

filename=$1
# create analysis dir for storage of data generated from this script
mkdir analysis/tcp_host_lists_by_svc
# create files of hosts by services, useful for performing service-specific scans
declare -a tcp_svcs=( \
	" ssh" " ftp$" " smtp" " telnet" \
	" http$" " https" " isakmp" " microsoft-ds" \
	" http-proxy" " ftps" " pop2$" " pop3$" " pop3s" " pop2s" \
	" netbios-ssn" " ms-wbt-server" " wsman" " ms-cluster-net" \
	" winrm" " msrpc" " nfs" " nrpe" " ident" \
	" smb" " printer" " jetdirect" " svrloc" " llmnr" \
	" globalcatLDAP$" " globalcatLDAPssl" " ldap$" " ldaps" " ssdp" \
	" upnp" " http-rpc-epmap" " domain" " sftp" \
	" kerberos-sec" " login" " shell$" \
	" exec$" " mysql" " ndmp" " imaps$" " iscsi" \
	" oracle-tns" " ms-sql" " ms-sql-s" " rtsp" " imap$" \
	" finger" " tacacs" " vnc" \
	)
tcp_file="analysis/nmap_scan_data/tcp-all-ports-${filename}.txt"
total_hosts=$(grep "Nmap scan report for" "${tcp_file}" | wc -l)
current_host=""

# analyze tcp file first
while read line; do
	# store host details
	new_host=$(echo "${line}" | grep "Nmap scan report for")
	finished=$(echo "${line}" | grep "Nmap done")
	
	# if line is the beginning of results for a different host or scans are finished and only one host was scanned, update current host
	# add results for completed host to analysis file (e.g. if ip in ssh-hosts, add note on ssh use)
	if [[ ! -z "$new_host" ]] ||  [[ ! -z "${finished}" && $total_hosts -eq 1 ]]; then 
		# add analysis for prev host if there was a prev host
		# update current host as last step
		current_host=$(echo $new_host | cut -d ' ' -f5-)
	fi

	# at this point, we have info on the current host and are ready to analyze services
	# first we are going to add host info to relevant file for service-specific scan scripts
	# e.g. if ssh discovered, add host to file named 'ssh-hosts'
	for svc in "${tcp_svcs[@]}"; do
		svc_present=$(echo "${line}" | grep "${svc}")
		if [[ ! -z "${svc_present}" ]]; then
			port=$(echo "${svc_present}" | cut -d '/' -f1)
			# strip spaces and dollar signs from svc for filename
			formatted_svc=$(echo "${svc}" | sed -e 's/^[ \t]*//' | tr -d $)
			# add host ip to hostlist for service (e.g. ssh-hosts.txt)
			ip=$(echo "${current_host}" | cut -d '(' -f2 | tr -d ')')
			echo "Adding ${ip} to ${formatted_svc}_hosts.txt"
			# add ip to list
			echo "${ip}" >> analysis/tcp_host_lists_by_svc/${formatted_svc}_hosts_no_port.txt
			# add ip and port to list- used in service scans
			echo "${ip}:${port}" >> analysis/tcp_host_lists_by_svc/${formatted_svc}_hosts.txt
		fi
	done
done < "${tcp_file}"
echo "Lists of hosts by TCP service generated."
echo "Now launching service scans."

./tcp_scan_analysis.sh "${filename}" &
stty echo
exit 0