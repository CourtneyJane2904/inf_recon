<h1>inf_recon</h1>
Automates the initial recon phase of an infrastructure assessment- launches TCP/UDP scans via nmap, analyzes results and performs further service-specific checks.

<h2>Usage</h2>
<ul>
    <li>
        Launch scans from list of IPs: <pre>inf_recon.sh [project name] -l [ip list file path]</pre>
    </li>
    <li>
        Launch scans on subnet: <pre>inf_recon.sh [project name] -s [ip.ip.ip.ip/cidr]</pre>
    </li>
</ul>

<h2>Arguments</h2>
<ul>
    <li><h3>project name</h3> this is used as the name for files holding hosts after being split in chunks of 64</li>
    <li><h3>-l|-s</h3> use the -l flag to source IPs from an existing IP list and the -s flag to specify a CIDR</li>
    <li><h3>ip list file path|ip.ip.ip.ip/cidr</h3> if -l, provide the file path to a list of IPs. If -s, provide a CIDR</li>
</ul>

<h2>Examples</h2>
<ul>
    <li><pre>./inf_recon.sh client -l /home/kali/list_of_ips</pre> split /home/kali/list_of_ips into 64-line files named client.000-client.999 and perform scans</li>
    <li><pre>./inf_recon.sh client -s 192.168.0.0/24</pre> generate list of IPs in 192.168.0.0/24, split into 64-line files named client.00-client.99 and perform scans</li>
</ul>

<h2>Limitations</h2>
<ul>
    <li>A maximum of 6400 hosts at a time is currently supported; this can be easily adjusted by making changes to inf_recon.sh, tcp_scans.sh and udp_scans.sh</li>
    <li>There is no idiot proofing as of now- make sure you provide valid arguments!</li>
    <li>The script must be run as root- not sudo, you must run the script logged in to the terminal as root. Bit annoying, probably something I'll work on in future</li>
</ul>

<h2>Disclaimer</h2>
<ul>
    <li>This is very much still a work in progress- there are already some things I have in mind to change in future such as separating *_scan_analysis.sh into separate files and organising the resulting directory structure better. I also want to add more to the service scan scripts as some nmap scripts don't work. The issue is having access to a testing environment for it that has a majority of the services checked for available! It does work, just ignore the mess. :)</li>
</ul>