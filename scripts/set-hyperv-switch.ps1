param([string]$vmName='master')

# See: https://www.thomasmaurer.ch/2016/01/change-hyper-v-vm-switch-of-virtual-machines-using-powershell/

if ("NATSwitch" -in (Get-VM -Name $vmName | Get-VMNetworkAdapter | Select-Object -ExpandProperty SwitchName) -eq $FALSE) {
  Write-Host 'Associate NATSwitch to the VM...'
  Get-VM -VMNAME $vmName | Get-VMNetworkAdapter | Connect-VMNetworkAdapter -SwitchName "NATSwitch"
}
