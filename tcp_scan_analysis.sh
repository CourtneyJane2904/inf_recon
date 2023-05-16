#!/bin/bash

filename=$1
# move results in nmap format to nmap-files directory
mkdir analysis
mkdir analysis/nmap_scan_data
mv scan_results/tcp/*.nmap analysis/nmap_scan_data
mkdir analysis/other_scan_data 
mv scan_results/tcp/tcp-all-ports* analysis/other_scan_data
# create master files holding results for whole subnet
echo "Merging scan results into one file..."
cat analysis/nmap_scan_data/tcp-all-ports* > analysis/nmap_scan_data/tcp-all-ports-${filename}.txt && echo "Merged TCP scan results."
# create analysis dir for storage of data generated from this script
mkdir analysis/host_lists_by_svc
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
		if [[ ! -z "$current_host" ]]; then
			ip=$(echo "${current_host}" | cut -d '(' -f2 | tr -d ')')
			hostname=$(echo "${current_host}" | cut -d '(' -f1 | tr -d ')')
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/ssh_hosts.txt) ]]; then
				port=$(grep "${ip}" analysis/host_lists_by_svc/ssh_hosts.txt | cut -d ':' -f2)
				echo "Adding SSH notes for ${ip}"
				text="SSH is present, please see https://book.hacktricks.xyz/network-services-pentesting/pentesting-ssh"
				echo "${text}" >> "analysis/${ip}_summary.txt"
				echo "Launching SSH scans"
				tests/ssh_scan.sh "${ip}" "${port}" &
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/sftp_hosts.txt) ]]; then
				port=$(grep "${ip}" analysis/host_lists_by_svc/sftp_hosts.txt | cut -d ':' -f2)
				echo "Adding SFTP notes for ${ip}"
				text="SFTP is present, please see https://book.hacktricks.xyz/network-services-pentesting/pentesting-ssh"
				echo "${text}" >> "analysis/${ip}_summary.txt"
				echo "Launching SSH scans"
				tests/ssh_scan.sh "${ip}" "${port}" &
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/vnc_hosts.txt) ]]; then
				port=$(grep "${ip}" analysis/host_lists_by_svc/vnc_hosts.txt | cut -d ':' -f2)
				echo "Adding VNC notes for ${ip}"
				text="VNC is present, please see https://book.hacktricks.xyz/network-services-pentesting/pentesting-vnc"
				echo "${text}" >> "analysis/${ip}_summary.txt"
				echo "Launching SSH scans"
				tests/vnc_scan.sh "${ip}" "${port}" &
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/ftp_hosts.txt) ]]; then
				port=$(grep "${ip}" analysis/host_lists_by_svc/ftp_hosts.txt | cut -d ':' -f2)
				echo "Adding FTP notes for ${ip}"
				text="FTP is present. This is an unencrypted service and shouldn't be used. please see https://book.hacktricks.xyz/network-services-pentesting/pentesting-ftp"
				echo "${text}" >> "analysis/${ip}_summary.txt"
				tests/ftp_scan.sh "${ip}" "${port}" &
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/ndmp_hosts.txt) ]]; then
				port=$(grep "${ip}" analysis/host_lists_by_svc/ndmp_hosts.txt | cut -d ':' -f2)
				echo "Adding NDMP notes for ${ip}"
				text="NDMP is present, please see https://book.hacktricks.xyz/network-services-pentesting/10000-network-data-management-protocol-ndmp"
				echo "${text}" >> "analysis/${ip}_summary.txt"
				tests/ndmp_scan.sh "${ip}" "${port}" &
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/smtp_hosts.txt) ]]; then
				port=$(grep "${ip}" analysis/host_lists_by_svc/smtp_hosts.txt | cut -d ':' -f2)
				echo "Adding SMTP notes for ${ip}"
				text="SMTP is present, indicating that the host is a mail server. This is an unencrypted service and shouldn't be used. please see https://book.hacktricks.xyz/network-services-pentesting/pentesting-smtp"
				echo "${text}" >> "analysis/${ip}_summary.txt"
				tests/smtp_scan.sh "${ip}" "${port}" &
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/telnet_hosts.txt) ]]; then
				port=$(grep "${ip}" analysis/host_lists_by_svc/telnet_hosts.txt | cut -d ':' -f2)
				echo "Adding telnet notes for ${ip}"
				text="Telnet is present. This is an unencrypted service and shouldn't be used. please see https://book.hacktricks.xyz/network-services-pentesting/pentesting-telnet"
				echo "${text}" >> "analysis/${ip}_summary.txt"
				tests/telnet_scan.sh "${ip}" "${port}" &
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/iscsi_hosts.txt) ]]; then
				port=$(grep "${ip}" analysis/host_lists_by_svc/iscsi_hosts.txt | cut -d ':' -f2)
				echo "Adding ISCSI notes for ${ip}"
				text="ISCSI is present, please see https://book.hacktricks.xyz/network-services-pentesting/3260-pentesting-iscsi"
				echo "${text}" >> "analysis/${ip}_summary.txt"
				tests/iscsi_scan.sh "${ip}" "${port}" &
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/http_hosts.txt) ]]; then
				port=$(grep "${ip}" analysis/host_lists_by_svc/http_hosts.txt | cut -d ':' -f2)
				echo "Adding HTTP notes for ${ip}"
				text="HTTP is present. This is an unencrypted service and shouldn't be used if the site stores sensitive data."
				echo "${text}" >> "analysis/${ip}_summary.txt"
				tests/http_scan.sh "${ip}" "${port}" &
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/ident_hosts.txt) ]]; then
				port=$(grep "${ip}" analysis/host_lists_by_svc/ident_hosts.txt | cut -d ':' -f2)
				echo "Adding IDENT notes for ${ip}"
				text="IDENT is present. This is an unencrypted service and shouldn't be used if the site stores sensitive data."
				echo "${text}" >> "analysis/${ip}_summary.txt"
				tests/ident_scan.sh "${ip}" "${port}" &
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/https_hosts.txt) ]]; then
				port=$(grep "${ip}" analysis/host_lists_by_svc/https_hosts.txt | cut -d ':' -f2)
				echo "Adding HTTPS notes for ${ip}"
				text="HTTPS is present."
				echo "${text}" >> "analysis/${ip}_summary.txt"
				tests/https_scan.sh "${ip}" "${port}" &
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/isakmp_hosts.txt) ]]; then
				port=$(grep "${ip}" analysis/host_lists_by_svc/isakmp_hosts.txt | cut -d ':' -f2)
				echo "Adding isakmp notes for ${ip}"
				text="isakmp is present, suggesting host is a VPN server. Please see https://book.hacktricks.xyz/network-services-pentesting/ipsec-ike-vpn-pentesting"
				echo "${text}" >> "analysis/${ip}_summary.txt"
				tests/ike_scan.sh "${ip}" "${port}" &
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/microsoft-ds_hosts.txt) ]]; then
				port=$(grep "${ip}" analysis/host_lists_by_svc/microsoft-ds_hosts.txt | cut -d ':' -f2)
				echo "Adding SMB notes for ${ip}"
				text="SMB is present, please see https://book.hacktricks.xyz/network-services-pentesting/pentesting-smb"
				echo "${text}" >> "analysis/${ip}_summary.txt"
				tests/microsoft-ds_scan.sh "${ip}" "${port}" &
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/http-proxy_hosts.txt) ]]; then
				port=$(grep "${ip}" analysis/host_lists_by_svc/http-proxy_hosts.txt | cut -d ':' -f2)
				echo "Adding HTTP proxy notes for ${ip}"
				text="HTTP proxy is present."
				echo "${text}" >> "analysis/${ip}_summary.txt"
				tests/http_scan.sh "${ip}" "${port}" &
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/ftps_hosts.txt) ]]; then
				port=$(grep "${ip}" analysis/host_lists_by_svc/ftps_hosts.txt | cut -d ':' -f2)
				echo "Adding FTPS notes for ${ip}"
				text="FTPS is present. Please see please see https://book.hacktricks.xyz/network-services-pentesting/pentesting-ftp"
				echo "${text}" >> "analysis/${ip}_summary.txt"
				tests/ftp_scan.sh "${ip}" "${port}" &
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/pop2_hosts.txt) ]]; then
				port=$(grep "${ip}" analysis/host_lists_by_svc/pop2_hosts.txt | cut -d ':' -f2)
				echo "Adding POP notes for ${ip}"
				text="POP2 is present, indicating that the host is a mail server. This is an unencrypted service and shouldn't be used. Please see please see https://book.hacktricks.xyz/network-services-pentesting/pentesting-pop"
				echo "${text}" >> "analysis/${ip}_summary.txt"
				tests/pop_scan.sh "${ip}" "${port}" &
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/pop3_hosts.txt) ]]; then
				port=$(grep "${ip}" analysis/host_lists_by_svc/pop3_hosts.txt | cut -d ':' -f2)
				echo "Adding POP3 notes for ${ip}"
				text="POP3 is present, indicating that the host is a mail server. This is an unencrypted service and shouldn't be used. Please see please see https://book.hacktricks.xyz/network-services-pentesting/pentesting-pop"
				echo "${text}" >> "analysis/${ip}_summary.txt"
				tests/pop_scan.sh "${ip}" "${port}" &
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/pop3s_hosts.txt) ]]; then
				port=$(grep "${ip}" analysis/host_lists_by_svc/pop3s_hosts.txt | cut -d ':' -f2)
				echo "Adding POP3s notes for ${ip}"
				text="POP3s is present, indicating that the host is a mail server. Please see please see https://book.hacktricks.xyz/network-services-pentesting/pentesting-pop"
				echo "${text}" >> "analysis/${ip}_summary.txt"
				tests/pop_scan.sh "${ip}" "${port}" &
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/netbios-ssn_hosts.txt) ]]; then
				port=$(grep "${ip}" analysis/host_lists_by_svc/netbios-ssn_hosts.txt | cut -d ':' -f2)
				echo "Adding netbios session service notes for ${ip}"
				text="Netbios Session Service is present, indicating that the host runs a Windows OS. Please see please see https://book.hacktricks.xyz/network-services-pentesting/137-138-139-pentesting-netbios"
				echo "${text}" >> "analysis/${ip}_summary.txt"
				tests/netbios_scan.sh "${filename}" "${ip}" "${port}" &
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/ms-wbt-server_hosts.txt) ]]; then
				port=$(grep "${ip}" analysis/host_lists_by_svc/ms-wbt-server_hosts.txt | cut -d ':' -f2)
				echo "Adding RDP notes for ${ip}"
				text="RDP is present, indicating that the host runs a Windows OS (though not definite.) Please see please see https://book.hacktricks.xyz/network-services-pentesting/pentesting-rdp"
				echo "${text}" >> "analysis/${ip}_summary.txt"
				tests/ms-wbt-server_scan.sh "${ip}" "${port}" &
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/wsman_hosts.txt) ]]; then
				echo "Adding Windows Remote Management notes for ${ip}"
				text="wsman is present which is a part of Windows Remote Management, indicating that the host runs a Windows OS and plays a role in AD infrastructure. Please see please see https://book.hacktricks.xyz/network-services-pentesting/5985-5986-pentesting-winrm"
				echo "${text}" >> "analysis/${ip}_summary.txt"
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/ms-cluster-net_hosts.txt) ]]; then
				echo "Adding ms-cluster-net notes for ${ip}"
				text="ms-cluster-net is present, indicating that the host is a Microsoft Cluster Server."
				echo "${text}" >> "analysis/${ip}_summary.txt"
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/winrm_hosts.txt) ]]; then
				echo "Adding Windows Remote Management notes for ${ip}"
				text="winrm is present, indicating that the host runs a Windows OS and plays a role in AD infrastructure. Please see https://book.hacktricks.xyz/network-services-pentesting/5985-5986-pentesting-winrm"
				echo "${text}" >> "analysis/${ip}_summary.txt"
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/msrpc_hosts.txt) ]]; then
				port=$(grep "${ip}" analysis/host_lists_by_svc/msrpc_hosts.txt | cut -d ':' -f2)
				echo "Adding RPC notes for ${ip}"
				text="RPC is present, indicating that the host runs a Windows OS and plays a role in AD infrastructure. Please see https://book.hacktricks.xyz/network-services-pentesting/135-pentesting-msrpc"
				echo "${text}" >> "analysis/${ip}_summary.txt"
				tests/msrpc_scan.sh "${ip}" "${port}" &
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/nfs_hosts.txt) ]]; then
				port=$(grep "${ip}" analysis/host_lists_by_svc/nfs_hosts.txt | cut -d ':' -f2)
				echo "Adding NFS notes for ${ip}"
				text="NFS is present. Please see https://book.hacktricks.xyz/network-services-pentesting/nfs-service-pentesting"
				echo "${text}" >> "analysis/${ip}_summary.txt"
				tests/nfs_scan.sh "${ip}" "${port}" &
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/nrpe_hosts.txt) ]]; then
				port=$(grep "${ip}" analysis/host_lists_by_svc/nrpe_hosts.txt | cut -d ':' -f2)
				echo "Adding NRPE notes for ${ip}"
				text="Nagios Remote Plugin Executer (NRPE) is present, indicating the host is Unix/Linux and monitored by Nagios."
				echo "${text}" >> "analysis/${ip}_summary.txt"
				tests/nrpe_scan.sh "${ip}" "${port}" &
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/printer_hosts.txt) ]]; then
				echo "Adding printer notes for ${ip}"
				text="printer service is present, indicating the host is a printer. https://book.hacktricks.xyz/network-services-pentesting/pentesting-printers"
				echo "${text}" >> "analysis/${ip}_summary.txt"
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/jetdirect_hosts.txt) ]]; then
				port=$(grep "${ip}" analysis/host_lists_by_svc/jetdirect_hosts.txt | cut -d ':' -f2)
				echo "Adding printer notes for ${ip}"
				text="jetdirect service is present, indicating the host is a printer. https://book.hacktricks.xyz/network-services-pentesting/9100-pjl"
				echo "${text}" >> "analysis/${ip}_summary.txt"
				tests/jetdirect_scan.sh "${ip}" "${port}" &
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/svrloc_hosts.txt) ]]; then
				echo "Adding svrloc notes for ${ip}"
				text="svrloc service is present, indicating the host is a printer as this is frequently used to locate printers."
				echo "${text}" >> "analysis/${ip}_summary.txt"
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/llmnr_hosts.txt) ]]; then
				echo "Adding llmnr notes for ${ip}"
				text="llmnr is present, this is spoofable and should be disabled. https://book.hacktricks.xyz/generic-methodologies-and-resources/pentesting-network/spoofing-llmnr-nbt-ns-mdns-dns-and-wpad-and-relay-attacks"
				echo "${text}" >> "analysis/${ip}_summary.txt"
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/globalcatLDAP_hosts.txt) ]]; then
				port=$(grep "${ip}" analysis/host_lists_by_svc/globalcatLDAP_hosts.txt | cut -d ':' -f2)
				echo "Adding global catalog notes for ${ip}"
				text="global catalog is present, indicating the network uses AD. This is unencrypted and shouldn't be used. https://book.hacktricks.xyz/network-services-pentesting/pentesting-ldap"
				echo "${text}" >> "analysis/${ip}_summary.txt"
				tests/ldap_scan.sh "${ip}" "${port}" &
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/globalcatLDAPssl_hosts.txt) ]]; then
				port=$(grep "${ip}" analysis/host_lists_by_svc/globalcatLDAPssl_hosts.txt | cut -d ':' -f2)
				echo "Adding global catalog notes for ${ip}"
				text="global catalog is present, indicating the network uses AD. https://book.hacktricks.xyz/network-services-pentesting/pentesting-ldap"
				echo "${text}" >> "analysis/${ip}_summary.txt"
				tests/ldap_scan.sh "${ip}" "${port}" &
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/ldap_hosts.txt) ]]; then
				port=$(grep "${ip}" analysis/host_lists_by_svc/ldap_hosts.txt | cut -d ':' -f2)
				echo "Adding LDAP notes for ${ip}"
				text="LDAP is present, indicating the host could be a domain controller. This is unencrypted and shouldn't be used. https://book.hacktricks.xyz/network-services-pentesting/pentesting-ldap"
				echo "${text}" >> "analysis/${ip}_summary.txt"
				tests/ldap_scan.sh "${ip}" "${port}" &
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/ldaps_hosts.txt) ]]; then
				port=$(grep "${ip}" analysis/host_lists_by_svc/ldaps_hosts.txt | cut -d ':' -f2)
				echo "Adding LDAPs notes for ${ip}"
				text="LDAPs is present, indicating the host could be a domain controller. https://book.hacktricks.xyz/network-services-pentesting/pentesting-ldap"
				echo "${text}" >> "analysis/${ip}_summary.txt"
				tests/ldap_scan.sh "${ip}" "${port}" &
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/ssdp_hosts.txt) ]]; then
				echo "Adding SSDP notes for ${ip}"
				text="SSDP is present, indicating the host is a UPNP device. SSDP is spoofable. https://book.hacktricks.xyz/generic-methodologies-and-resources/pentesting-network/spoofing-ssdp-and-upnp-devices"
				echo "${text}" >> "analysis/${ip}_summary.txt"
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/upnp_hosts.txt) ]]; then
				echo "Adding UPNP notes for ${ip}"
				text="UPNP is present, indicating the host is a UPNP device. SSDP is spoofable. https://book.hacktricks.xyz/generic-methodologies-and-resources/pentesting-network/spoofing-ssdp-and-upnp-devices"
				echo "${text}" >> "analysis/${ip}_summary.txt"
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/http-rpc-epmap_hosts.txt) ]]; then
				echo "Adding HTTP RPC endpoint mapper notes for ${ip}"
				text="http-rpc-epmap is present, indicating that the host runs a Windows OS and plays a role in AD infrastructure. Please see https://book.hacktricks.xyz/network-services-pentesting/135-pentesting-msrpc"
				echo "${text}" >> "analysis/${ip}_summary.txt"
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/domain_hosts.txt) ]]; then
				port=$(grep "${ip}" analysis/host_lists_by_svc/domain_hosts.txt | cut -d ':' -f2)
				echo "Adding DNS notes for ${ip}"
				text="DNS is present, indicating that the host is a DNS server. May also indicate host is a domain controller. Please see https://book.hacktricks.xyz/network-services-pentesting/pentesting-dns"
				echo "${text}" >> "analysis/${ip}_summary.txt"
				tests/domain_scan.sh "${ip}" "${port}" &
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/kerberos-sec_hosts.txt) ]]; then
				echo "Adding Kerberos notes for ${ip}"
				text="Kerberos is present, indicating that the host is a domain controller. Please see https://book.hacktricks.xyz/network-services-pentesting/pentesting-kerberos-88 and https://www.hackingarticles.in/abusing-kerberos-using-impacket/"
				echo "${text}" >> "analysis/${ip}_summary.txt"
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/login_hosts.txt) ]]; then
				echo "Adding rlogin notes for ${ip}"
				text="rlogin is present, indicating that the host is running Windows. This is insecure, unencrypted and shouldn't be used. Please see https://book.hacktricks.xyz/network-services-pentesting/pentesting-rlogin"
				echo "${text}" >> "analysis/${ip}_summary.txt"
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/exec_hosts.txt) ]]; then
				echo "Adding rexec notes for ${ip}"
				text="rexec is present, indicating that the host is running Windows. This is unencrypted and shouldn't be used. Please see https://book.hacktricks.xyz/network-services-pentesting/pentesting-rexec"
				echo "${text}" >> "analysis/${ip}_summary.txt"
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/shell_hosts.txt) ]]; then
				echo "Adding rsh notes for ${ip}"
				text="rsh is present, indicating that the host is running Windows. This is insecure, unencrypted and shouldn't be used. Please see https://book.hacktricks.xyz/network-services-pentesting/pentesting-rsh"
				echo "${text}" >> "analysis/${ip}_summary.txt"
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/mysql_hosts.txt) ]]; then
				port=$(grep "${ip}" analysis/host_lists_by_svc/mysql_hosts.txt | cut -d ':' -f2)
				echo "Adding mysql notes for ${ip}"
				text="mysql is present. Please see https://book.hacktricks.xyz/network-services-pentesting/pentesting-mysql"
				echo "${text}" >> "analysis/${ip}_summary.txt"
				tests/mysql_scan.sh "${ip}" "${port}" &
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/oracle-tns_hosts.txt) ]]; then
				port=$(grep "${ip}" analysis/host_lists_by_svc/oracle-tns_hosts.txt | cut -d ':' -f2)
				echo "Adding Oracle notes for ${ip}"
				text="Oracle is present. Please see https://book.hacktricks.xyz/network-services-pentesting/1521-1522-1529-pentesting-oracle-listener"
				echo "${text}" >> "analysis/${ip}_summary.txt"
				tests/oracle-tns_scan.sh "${ip}" "${port}" &
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/ms-sql_hosts.txt) ]]; then
				port=$(grep "${ip}" analysis/host_lists_by_svc/ms-sql_hosts.txt | cut -d ':' -f2)
				echo "Adding MS SQL notes for ${ip}"
				text="MS SQL is present. Please see https://book.hacktricks.xyz/network-services-pentesting/pentesting-mssql-microsoft-sql-server"
				echo "${text}" >> "analysis/${ip}_summary.txt"
				tests/ms-sql_scan.sh "${ip}" "${port}" &
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/imap_hosts.txt) ]]; then
				port=$(grep "${ip}" analysis/host_lists_by_svc/imap_hosts.txt | cut -d ':' -f2)
				echo "Adding IMAP notes for ${ip}"
				text="IMAP is present, indicating that the host is a mail server. Please see https://book.hacktricks.xyz/network-services-pentesting/pentesting-imap"
				echo "${text}" >> "analysis/${ip}_summary.txt"
				tests/imap_scan.sh "${ip}" "${port}" &
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/imaps_hosts.txt) ]]; then
				port=$(grep "${ip}" analysis/host_lists_by_svc/imaps_hosts.txt | cut -d ':' -f2)
				echo "Adding IMAP notes for ${ip}"
				text="IMAP is present, indicating that the host is a mail server. Please see https://book.hacktricks.xyz/network-services-pentesting/pentesting-imap"
				echo "${text}" >> "analysis/${ip}_summary.txt"
				tests/imap_scan.sh "${ip}" "${port}" &
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/rtsp_hosts.txt) ]]; then
				port=$(grep "${ip}" analysis/host_lists_by_svc/rtsp_hosts.txt | cut -d ':' -f2)
				echo "Adding RTSP notes for ${ip}"
				text="RTSP is present, indicating that the host is a media server. Please see https://book.hacktricks.xyz/network-services-pentesting/554-8554-pentesting-rtsp"
				echo "${text}" >> "analysis/${ip}_summary.txt"
				tests/rtsp_scan.sh "${ip}" "${port}" &
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/tacacs_hosts.txt) ]]; then
				port=$(grep "${ip}" analysis/host_lists_by_svc/tacacs_hosts.txt | cut -d ':' -f2)
				echo "Adding TACACS notes for ${ip}"
				text="TACACS is present, please see https://book.hacktricks.xyz/network-services-pentesting/49-pentesting-tacacs+"
				echo "${text}" >> "analysis/${ip}_summary.txt"
			fi
			if [[ ! -z $(grep "${ip}" analysis/host_lists_by_svc/finger_hosts.txt) ]]; then
				port=$(grep "${ip}" analysis/host_lists_by_svc/finger_hosts.txt | cut -d ':' -f2)
				echo "Adding finger notes for ${ip}"
				text="Finger is present, please see https://book.hacktricks.xyz/network-services-pentesting/pentesting-finger"
				echo "${text}" >> "analysis/${ip}_summary.txt"
				tests/finger_scan.sh "${ip}" "${port}" &
			fi
		fi
		# update current host as last step
		current_host=$(echo $new_host | cut -d ' ' -f5-)
	fi

	# continue if current host empty- means we haven't reached results yet
	if [[ -z "$current_host" ]]; then continue; fi

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
			echo "${ip}" >> analysis/host_lists_by_svc/${formatted_svc}_hosts_no_port.txt
			# add ip and port to list- used in service scans
			echo "${ip}:${port}" >> analysis/host_lists_by_svc/${formatted_svc}_hosts.txt
		fi
	done
done < "${tcp_file}"
echo "TCP analysis complete."
stty echo
exit 0