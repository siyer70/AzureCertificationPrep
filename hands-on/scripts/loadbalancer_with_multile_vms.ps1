New-AzureRmResourceGroup -Name "az533lbtest-rg" -Location "CentralIndia"

$pubip = New-AzureRmPublicIpAddress -Name "az533lbpubip" -ResourceGroupName "az533lbtest-rg" -Location "centralindia" -AllocationMethod Static

$lbfpool = New-AzureRmLoadBalancerFrontendIpConfig -Name "az533lbfpool" -PublicIpAddress $pubip 
$lbbpool = New-AzureRmLoadBalancerBackendAddressPoolConfig -Name "az533lbbpool"

$lb = New-AzureRmLoadBalancer -Name "az533lb" -ResourceGroupName "az533lbtest-rg" -Location "centralIndia" -FrontendIpConfiguration $lbfpool -BackendAddressPool $lbbpool

Add-AzureRmLoadBalancerProbeConfig -Name "az533lbprobe" -LoadBalancer $lb -Protocol Tcp -IntervalInSeconds 15 -Port 80 -ProbeCount 2

Set-AzureRmLoadBalancer -LoadBalancer $lb

$probe = Get-AzureRmLoadBalancerProbeConfig -Name "az533lbprobe" -LoadBalancer $lb
Add-AzureRmLoadBalancerRuleConfig -Name "az533lbrule" -LoadBalancer $lb -Probe $probe -Protocol Tcp -FrontendPort 80 -BackendPort 80 -FrontendIpConfiguration $lb.FrontendIpConfigurations[0] -BackendAddressPool $lb.BackendAddressPools[0]
Set-AzureRmLoadBalancer -LoadBalancer $lb

$subnet = New-AzureRmVirtualNetworkSubnetConfig -Name "az533lbsubnet" -AddressPrefix 10.0.1.0/24 
$vnet = New-AzureRmVirtualNetwork -Name "az533lbvnet" -ResourceGroupName "az533lbtest-rg" -Location "centralIndia" -AddressPrefix 10.0.0.0/16 -Subnet $subnet

for($i=1; $i -le 3; $i++) { New-AzureRmNetworkInterface -Name "az533nic$i" -ResourceGroupName "az533lbtest-rg" -Location "centralIndia" -Subnet $vnet.Subnets[0] -LoadBalancerBackendAddressPool $lb.BackendAddressPools[0] }

$availset = New-AzureRmAvailabilitySet -ResourceGroupName "az533lbtest-rg" -Name "az533avset" -Location "CentralIndia" -PlatformUpdateDomainCount 4 -PlatformFaultDomainCount 2 -Sku aligned

$cred = Get-Credential

for($i=1; $i -le 3; $i++) { New-AzureRmVM -Name "az533lbvm$i" -ResourceGroupName "az533lbtest-rg" -Location "centralIndia" -VirtualNetworkName "az533lbvnet" -SubnetName "az533lbsubnet" -Credential $cred -SecurityGroupName "az533lbnsg" -OpenPorts 80 -AvailabilitySetName "az533avset"}

for($i=1; $i -le 3; $i++) { Set-AzureRmVMExtension -Publisher Microsoft.Compute -ExtensionType CustomScriptExtension -ResourceGroupName "az533lbtest-rg" -Name "az533lbext$i" -VMName "az533lbvm$i" -Location "CentralIndia" -TypeHandlerVersion 1.8 -SettingString '{"commandToExecute":"powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"}'}

$nic = Get-AzureRmNetworkInterface `
    -ResourceGroupName "myResourceGroupLoadBalancer" `
    -Name "myVM2"
$nic.Ipconfigurations[0].LoadBalancerBackendAddressPools=$null
Set-AzureRmNetworkInterface -NetworkInterface $nic

$lb = Get-AzureRMLoadBalancer `
    -ResourceGroupName myResourceGroupLoadBalancer `
    -Name myLoadBalancer 
$nic.IpConfigurations[0].LoadBalancerBackendAddressPools=$lb.BackendAddressPools[0]
Set-AzureRmNetworkInterface -NetworkInterface $nic

