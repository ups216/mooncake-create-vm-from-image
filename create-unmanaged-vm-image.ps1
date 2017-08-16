## Parameters

$subName = "MVP150-LEIXU-3"
$rgName = "LX-SYSPREP02-RG"
$vmName = "lx-sysprep02"

## LOGIN ACCOUNT
Login-AzureRmAccount
Get-AzureRmSubscription
Select-AzureRmSubscription -SubscriptionName $subName
Get-AzureRmVM

## Prepare the VM
Stop-AzureRmVM -ResourceGroupName $rgName  -Name $vmName
Set-AzureRmVm -ResourceGroupName $rgName -Name $vmName -Generalized 
$vm = Get-AzureRmVM -ResourceGroupName $rgName -Name $vmName -Status
$vm.Statuses

## Taking the image
Save-AzureRmVMImage -ResourceGroupName $rgName -Name $vmName `
    -DestinationContainerName images -VHDNamePrefix lx-tempalte `
    -Path C:\dataleixu\script\201-vm-custom-image-new-storage-account\lx-sysprep01.json