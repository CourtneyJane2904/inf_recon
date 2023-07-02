#!/bin/bash

filename=$1
# create analysis dir for storage of data generated from this script
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
	" oracle-tns" " ms-sql" " rtsp" " imap$" \
	" finger" " tacacs" " vnc" \
	)

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