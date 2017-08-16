New-AzureRmResourceGroup -Name "lx-vmfromimage03-rg" -Location "eastasia"

New-AzureRmResourceGroupDeployment -Name "myDeploymentName" -ResourceGroupName "lx-vmfromimage03-rg" -Mode Incremental -TemplateFile .\azuredeploy.json -TemplateParameterFile .\azuredeploy.parameters.json -Force -Verbose 