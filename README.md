customize-nested.sh - Nested ESXi customization script
clonenested.ps1 - Deploy X Nested ESXi VMs from a Nested ESX*


* Requires ESXi 6.7, PowerCLI 10.1, and my SC/2N Module (https://code.vmware.com/samples/3734

1. Load a Nested ESXi host on an ESXi 6.7 host** 
2. Copy customize-nested.sh to /tmp/
3. Change permissions of /tmp/customize-nested.sh to 755
	(chmod 755 /tmp/customize-nested)
4. Suggest taking a snapshot of the Nested VM here
5. Execute the customize-nested.sh (/tmp/customize-nested.sh)
6. Make sure you're logged into the VCSA/ESXi that the Nested ESXi is running on (Connect-VIServer)
7. Load the VSANSC2N Module
8. Execute the clonenested.ps1 (with your settings updated)

**Tested with William Lam's Nested vSphere 6.5d ESXi OVA
https://www.virtuallyghetto.com/2015/12/deploying-nested-esxi-is-even-easier-now-with-the-esxi-virtual-appliance.html