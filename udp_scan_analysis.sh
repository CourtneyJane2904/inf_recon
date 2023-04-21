#!/bin/bash

filename=$1
# move results in nmap format to nmap-files directory
mkdir analysis
mkdir analysis/nmap_scan_data
mv scan_results/udp/*.nmap analysis/nmap_scan_data
mkdir analysis/other_scan_data
mv scan_results/udp/udp-popular-ports* analysis/other_scan_data
# create master files holding results for whole subnet
echo "Merging scan results into one file..."
cat analysis/nmap_scan_data/udp-popular-ports* > analysis/nmap_scan_data/udp-pop-ports-${filename}.txt && echo "Merged UDP scan results."
# create analysis dir for storage of data generated from this script
mkdir analysis/host_lists_by_svc
# create files of hosts by services, useful for performing service-specific scans
declare -a udp_svcs=( \
	" snmp" " tftp" " domain" \
	" nat-t-ike" " syslog" \
	" asf-rmcp" " netbios-ns" \
	" netbios-dgm" " zeroconf" " svrloc" \
	" rpcbind" " ndmp" " ws-discovery" " wap-wsp" \
	" ntp" " llmnr" " mdns" " upnp" " kpasswd5" \
	)

udp_file="analysis/nmap_scan_data/udp-pop-ports-${filename}.txt"
current_host=""

# analyze tcp file first
while read line; do
	# store host details
	new_host=$(echo "${line}" | grep "Nmap scan report for")

	# if line is the beginning of results for a different host, update current host
	# add results for completed host to analysis file (e.g. if ip in ssh-hosts, add note on ssh use)
	if [[ ! -z "$new_host" ]]; then 
		# add analysis for prev host if there was a prev host
		if [[ ! -z "$current_host" ]]; then
			ip=$(echo "${current_host}" | cut -d '(' -f2 | tr -d ')')
			hostname=$(echo "${current_host}" | cut -d '(' -f1 | tr -d ')')
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/snmp_hosts.txt) ]]; then
				port=$(grep "${ip}" analysis/host_lists_by_svc/snmp_hosts.txt | cut -d ':' -f2)
				echo "Adding SNMP notes for ${ip}"
				text="SNMP is present, SNMP v1 and v2 are insecure, unencrypted and shouldn't be used. please see https://book.hacktricks.xyz/network-services-pentesting/pentesting-snmp"
				echo "${ip}: ${text}" >> "analysis/${ip}_summary.txt"
				tests/snmp_scan.sh "${ip}" "${port}" &
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/tftp_hosts.txt) ]]; then
				port=$(grep "${ip}" analysis/host_lists_by_svc/tftp_hosts.txt | cut -d ':' -f2)
				echo "Adding TFTP notes for ${ip}"
				text="TFTP is present. This is an unencrypted and unauthenticated service and shouldn't be used. please see https://book.hacktricks.xyz/network-services-pentesting/69-udp-tftp"
				echo "${ip}: ${text}" >> "analysis/${ip}_summary.txt"
				tests/tftp_scan.sh "${ip}" "${port}" &
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/domain_hosts.txt) ]]; then
				echo "Adding DNS notes for ${ip}"
				text="DNS is present, indicating that the host is a DNS server. May also indicate host is a domain controller. Please see https://book.hacktricks.xyz/network-services-pentesting/pentesting-dns"
				echo "${ip}: ${text}" >> "analysis/${ip}_summary.txt"
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/nat-t-ike_hosts.txt) ]]; then
				echo "Adding nat-t-ike notes for ${ip}"
				text="nat-t-ike is present, indicating that the host is a VPN server."
				echo "${ip}: ${text}" >> "analysis/${ip}_summary.txt"
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/syslog_hosts.txt) ]]; then
				echo "Adding sys notes for ${ip}"
				text="rsh is present, indicating that the host is running Windows. This is insecure, unencrypted and shouldn't be used. Please see https://book.hacktricks.xyz/network-services-pentesting/pentesting-rsh"
				echo "${ip}: ${text}" >> "analysis/${ip}_summary.txt"
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/asf-rmcp_hosts.txt) ]]; then
				port=$(grep "${ip}" analysis/host_lists_by_svc/asf-rmcp_hosts.txt | cut -d ':' -f2)
				echo "Adding IPMI notes for ${ip}"
				text="asf-rmcp is present, indicating that the host is managed by an IPMI. Please see https://book.hacktricks.xyz/network-services-pentesting/623-udp-ipmi"
				echo "${ip}: ${text}" >> "analysis/${ip}_summary.txt"
				tests/asf-rmcp_scan.sh "${ip}" "${port}" &
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/netbios-ns_hosts.txt) ]]; then
				port=$(grep "${ip}" analysis/host_lists_by_svc/netbios-ns_hosts.txt | cut -d ':' -f2)
				echo "Adding netbios notes for ${ip}"
				text="netbios name service is present, indicating that the host is Windows. This is spoofable and should be disabled. https://book.hacktricks.xyz/generic-methodologies-and-resources/pentesting-network/spoofing-llmnr-nbt-ns-mdns-dns-and-wpad-and-relay-attacks"
				echo "${ip}: ${text}" >> "analysis/${ip}_summary.txt"
				tests/netbios_scan.sh "${filename}" "${ip}" "${port}" &
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/netbios-dgm_hosts.txt) ]]; then
				port=$(grep "${ip}" analysis/host_lists_by_svc/netbios-dgm_hosts.txt | cut -d ':' -f2)
				echo "Adding netbios notes for ${ip}"
				text="netbios datagram service is present, indicating that the host is Windows. Netbios NS is spoofable and should be disabled. https://book.hacktricks.xyz/generic-methodologies-and-resources/pentesting-network/spoofing-llmnr-nbt-ns-mdns-dns-and-wpad-and-relay-attacks"
				echo "${ip}: ${text}" >> "analysis/${ip}_summary.txt"
				tests/netbios_scan.sh "${filename}" "${ip}" "${port}" &
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/zeroconf_hosts.txt) ]]; then
				echo "Adding mDNS notes for ${ip}"
				text="mDNS is present, indicating that the host is Windows. This is spoofable and should be disabled. https://book.hacktricks.xyz/generic-methodologies-and-resources/pentesting-network/spoofing-llmnr-nbt-ns-mdns-dns-and-wpad-and-relay-attacks and https://book.hacktricks.xyz/network-services-pentesting/5353-udp-multicast-dns-mdns"
				echo "${ip}: ${text}" >> "analysis/${ip}_summary.txt"
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/svrloc_hosts.txt) ]]; then
				echo "Adding SLP notes for ${ip}"
				text="SLP is present, indicating that the host could be a printer."
				echo "${ip}: ${text}" >> "analysis/${ip}_summary.txt"
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/rpcbind_hosts.txt) ]]; then
				echo "Adding rpcbind notes for ${ip}"
				text="rpcbind is present, please see https://book.hacktricks.xyz/network-services-pentesting/pentesting-rpcbind"
				echo "${ip}: ${text}" >> "analysis/${ip}_summary.txt"
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/ndmp_hosts.txt) ]]; then
				port=$(grep "${ip}" analysis/host_lists_by_svc/ndmp_hosts.txt | cut -d ':' -f2)
				echo "Adding NDMP notes for ${ip}"
				text="NDMP is present, please see https://book.hacktricks.xyz/network-services-pentesting/10000-network-data-management-protocol-ndmp"
				echo "${ip}: ${text}" >> "analysis/${ip}_summary.txt"
				tests/ndmp_scan.sh "${ip}" "${port}" &
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/ws-discovery_hosts.txt) ]]; then
				echo "Adding WS-Discovery notes for ${ip}"
				text="Web Services Dynamic Discovery protocol is present which is used to locate services on a local network, please see https://book.hacktricks.xyz/network-services-pentesting/3702-udp-pentesting-ws-discovery"
				echo "${ip}: ${text}" >> "analysis/${ip}_summary.txt"
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/llmnr_hosts.txt) ]]; then
				echo "Adding LLMNR notes for ${ip}"
				text="Link-Name Local Multicast Name Resolution (LLMNR) is present which suggests there are Windows hosts on the network. This is spoofable and should be disabled, please see https://book.hacktricks.xyz/generic-methodologies-and-resources/pentesting-network/spoofing-llmnr-nbt-ns-mdns-dns-and-wpad-and-relay-attacks"
				echo "${ip}: ${text}" >> "analysis/${ip}_summary.txt"
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/wap-wsp_hosts.txt) ]]; then
				echo "Adding WAP-WSP notes for ${ip}"
				text="Elasticsearch is present which is used for data analytics, please see https://book.hacktricks.xyz/network-services-pentesting/9200-pentesting-elasticsearch"
				echo "${ip}: ${text}" >> "analysis/${ip}_summary.txt"
			fi
		fi
		# update current host as last step
		current_host=$(echo $new_host | cut -d ' ' -f5-);
	fi

	# continue if current host empty- means we haven't reached results yet
	if [[ -z "$current_host" ]]; then continue; fi

	# at this point, we have info on the current host and are ready to analyze services
	# first we are going to add host info to relevant file for service-specific scan scripts
	# e.g. if ssh discovered, add host to file named 'ssh-hosts'
	for svc in "${udp_svcs[@]}"; do
		svc_present=$(echo "${line}" | grep "${svc}")
		if [[ ! -z "${svc_present}" ]]; then
			port=$(echo "${svc_present}" | cut -d '/' -f1)
			# strip spaces and dollar signs from svc for filename
			formatted_svc=$(echo "${svc}" | sed -e 's/^[ \t]*//' | tr -d $)
			# add host ip to hostlist for service (e.g. ssh-hosts.txt)
			ip=$(echo "${current_host}" | cut -d '(' -f2 | tr -d ')')
			echo "Adding ${ip} to ${formatted_svc}_hosts.txt"
			echo "${ip}:${port}" >> analysis/host_lists_by_svc/${formatted_svc}_hosts.txt
		fi
	done
done < "${udp_file}"
echo "UDP analysis complete"
stty echo
exit 0