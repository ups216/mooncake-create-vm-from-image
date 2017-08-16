#### Parameters ################################################################
$chinaAzureUserName = "" ## example: leixu@leixu.partner.onmschina.cn
$chinaAzurePassword = ""
$chinaAzureLocation = "ChinaNorth"
$chinaAzureSubName = "ls-mc-test-env"
$rgGroupName = "azure-bootcamp-env-rg001" ## use build number to genrate unique resource group
$vmUsername = "azureuser" ## user same username and password for Windows & Linux
$vmPassword = "P2ssw0rd@123"
$vmWindowsSize = "Standard_D2"
$vmWindowsImage = "ls-win2016en-vs-image-20170814-01"
$vmWindowsImageRgName ="LX-WIN-TEMP02-RG"
$vmLinuxSize = "Standard_D1"
$vmLinuxImage = ""
$vmLinuxImageRgName = "LX-WIN-TEMP02-RG"
##################################################################################

# Login to Azure automatically 
$SecurePassword = ConvertTo-SecureString -String $chinaAzurePassword -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential `
     -argumentlist $chinaAzureUserName, $SecurePassword

Login-AzureRmAccount -Environment AzureChinaCloud -Credential $cred
Select-AzureRmSubscription -SubscriptionName $chinaAzureSubName

# seutp vm 
$vmUserName = $vmUsername
$vmSecuredPassword = ConvertTo-SecureString -String $vmPassword -AsPlainText -Force
$vmCred = new-object -typename System.Management.Automation.PSCredential `
     -argumentlist $vmUserName, $vmSecuredPassword

New-AzureRmResourceGroup -Name $rgGroupName -Location $chinaAzureLocation

$subnetConfig = New-AzureRmVirtualNetworkSubnetConfig `
    -Name mySubnet `
    -AddressPrefix 192.168.1.0/24

$vnet = New-AzureRmVirtualNetwork `
    -ResourceGroupName $rgGroupName `
    -Location $chinaAzureLocation `
    -Name MYvNET `
    -AddressPrefix 192.168.0.0/16 `
    -Subnet $subnetConfig

$pip = New-AzureRmPublicIpAddress `
    -ResourceGroupName $rgGroupName `
    -Location $chinaAzureLocation `
    -Name "mypublicdns$(Get-Random)" `
    -AllocationMethod Static `
    -IdleTimeoutInMinutes 4

$pip

$nsgRuleRDP = New-AzureRmNetworkSecurityRuleConfig `
    -Name myNetworkSecurityGroupRuleRDP `
    -Protocol Tcp `
    -Direction Inbound `
    -Priority 1000 `
    -SourceAddressPrefix * `
    -SourcePortRange * `
    -DestinationAddressPrefix * `
    -DestinationPortRange 3389 `
    -Access Allow


$nsg = New-AzureRmNetworkSecurityGroup `
    -ResourceGroupName $rgGroupName `
    -Location $chinaAzureLocation `
    -Name myNetworkSecurityGroup `
    -SecurityRules $nsgRuleRDP

$nic = New-AzureRmNetworkInterface `
    -Name myNic `
    -ResourceGroupName $rgGroupName `
    -Location $chinaAzureLocation `
    -SubnetId $vnet.Subnets[0].Id `
    -PublicIpAddressId $pip.Id `
    -NetworkSecurityGroupId $nsg.Id

$nic

$vmConfig = New-AzureRmVMConfig `
    -VMName myVMfromImage `
    -VMSize $vmWindowsSize | Set-AzureRmVMOperatingSystem -Windows `
        -ComputerName windev `
        -Credential $vmCred 

# Here is where we create a variable to store information about the image 
$image = Get-AzureRmImage `
    -ImageName $vmWindowsImage `
    -ResourceGroupName $vmWindowsImageRgName

# Here is where we specify that we want to create the VM from and image and provide the image ID
$vmConfig = Set-AzureRmVMSourceImage -VM $vmConfig -Id $image.Id

$vmConfig = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $nic.Id

$vm = New-AzureRmVM `
    -ResourceGroupName $rgGroupName `
    -Location $chinaAzureLocation `
    -VM $vmConfig

$vm 
