#!/bin/sh
# Author: Jase McCarty
# Contact: @jasemccarty
# Description: Tested on vSAN Witness Appliance
# Date: 12 MAY 18

set -x
exec 2>/tmp/ic-customization.log

echo -e "\n=== Start Pre-Freeze ==="

echo "Setting Mac to follow NIC"
/bin/esxcli.py system settings advanced set -o /Net/FollowHardwareMac -i 1

echo "Removing the UUID"
sed -e "/\/system\/uuid/d" -e /etc/vmware/esx.conf 

echo "Removing SSL certificates"
rm "/etc/vmware/ssl/rui.crt"
rm "/etc/vmware/ssl/rui.key"

echo "Run auto-backup"
/sbin/auto-backup.sh

echo "Removing vmk0"
/bin/esxcli.py network ip interface remove --interface-name=vmk0

echo -e "=== End of Pre-Freeze ===\n"

echo -e "Freezing ...\n"

/bin/vmtoolsd --cmd "instantclone.freeze"

echo -e "\n=== Start Post-Freeze ==="

# retrieve VM customization info passed from vSphere API
echo "Retrieving the OVF Properties"
HOSTNAME=$(/bin/vmtoolsd --cmd "info-get guestinfo.ic.hostname")
VMK0IP=$(/bin/vmtoolsd --cmd "info-get guestinfo.ic.vmk0.ip")
VMK0MASK=$(/bin/vmtoolsd --cmd "info-get guestinfo.ic.vmk0.netmask")
VMK0GATEWAY=$(/bin/vmtoolsd --cmd "info-get guestinfo.ic.vmk0.gateway")
DNS=$(/bin/vmtoolsd --cmd "info-get guestinfo.ic.dns")
NTP=$(/bin/vmtoolsd --cmd "info-get guestinfo.ic.ntp")

echo "Creating the Management Network"
/bin/esxcli.py network ip interface add -p "Management Network" -i vmk0
/bin/esxcli.py network ip interface ipv4 set -i vmk0 -I $VMK0IP -N $VMK0MASK -t static 
/bin/esxcli.py network ip dns server add --server=$DNS 
/bin/esxcli.py system hostname set --fqdn=$HOSTNAME
/bin/esxcfg-route -a default $VMK0GATEWAY

echo "Restarting Management Agents"
/etc/init.d/hostd restart
/etc/init.d/vpxa restart 

echo "Generating SSL keys"
/bin/generate-certificates

echo "=== End of Post-Freeze ==="

echo -e "\nCheck /root/ic-customization.log for details\n\n"
