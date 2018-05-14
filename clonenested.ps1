$SourceVM = "NESTED_65"
 
$numOfVMs = 25
$vmk0ipNetwork = "192.168.120"
$ipStartingCount=101
$ipSC=101
$vmk0netmask = "255.255.255.0"

$dns = "192.168.1.1"
$ntp = "192.168.1.1"

$vmk0gw = "192.168.120.1"

$MainDatacenter = Get-Datacenter -Name "Datacenter"

$StartTime = Get-Date
foreach ($i in 1..$numOfVMs) {
    $newVMName = "NESTED-ESXI-$i"
    $newVMIP = "$vmk0ipNetwork.$ipStartingCount"
 
    $guestCustomizationValues = @{
        "guestinfo.ic.hostname" = "$newVMName.nested.local"
        "guestinfo.ic.vmk0.ip" = "$vmk0ipNetwork.$ipStartingCount"
        "guestinfo.ic.vmk0.netmask" = "$vmk0netmask"
        "guestinfo.ic.vmk0.gateway" = "$vmk0gw"
        "guestinfo.ic.dns" = "$dns"
        "guestinfo.ic.ntp" = "$ntp"
        "guestinfo.ic.sourcevm" = "$SourceVM"
    }
    New-InstantClone -SourceVM $SourceVM -DestinationVM $newVMName -CustomizationFields $guestCustomizationValues
    $ipStartingCount++
    #Add-VMHost -Name $newVMIP -Location $MainDatacenter -user "root" -password "VMware1!" -Force -RunAsync
}

$EndTime = Get-Date
$duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalMinutes,2)
 
Write-Host -ForegroundColor Cyan  "`nTotal Instant Clones: $numOfVMs"
Write-Host -ForegroundColor Cyan  "StartTime: $StartTime"
Write-Host -ForegroundColor Cyan  "  EndTime: $EndTime"
Write-Host -ForegroundColor Green " Duration: $duration minutes"

Start-Sleep -s 15

$StartTime2 = Get-Date
foreach ($j in 1..$numOfVMs) {
    $newVMIP = "$vmk0ipNetwork.$ipSC"
    #Write-Host "NEW IP" $newVMIP 
    Add-VMHost -Name $newVMIP -Location (Get-Datacenter -Name "Nested") -user "root" -password "VMware1!" -Force
    $ipSC++    
}

$EndTime = Get-Date
$hostduration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalMinutes,2)
Write-Host -ForegroundColor Green " Duration to add hosts: $hostduration minutes"