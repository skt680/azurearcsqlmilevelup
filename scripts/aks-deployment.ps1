# from user
$subscription = Read-Host -Prompt "Input your subscription Id"
write-Host "Retrieving list of regions"
$allRegions = ((az account list-locations) | convertfrom-json) | sort-object name | select-object name
write-host $allRegions
$region = Read-Host - Prompt "Please input region where you want to host your aks cluster"
$directconnectivity = Read-Host - prompt "Are you using for direct connectivity 'Yes/No'"


# Default value start
$rg_name="levelupaks_lab"
#$StableVersion = "1.22.11"
$StableVersion = ((az aks get-versions --location uksouth --query orchestrators | convertfrom-json) | where-object {$_.default -eq "True"}).orchestratorVersion
#Need to automate with variable to catch the stable version for default value
'''
az aks get-versions --location  --$region  orchestrators -o table
'''
if($directconnectivity -eq "Yes")
{
    $aksname = "aksdirect"
}
else{ $aksname = "aksindirect"
}



# Default value End

#az login 
az account set --subscription "$subscription"

try
{
    Write-Host "Creating resource group $rg_name in region $region"
    $run_command = az group create --name $rg_name --location $region

}
catch
{
    $errormessage = $_
    
    Write-Host "Script failed creating resource group with error :  "
    throw $errormessage
        
}

try
{
    Write-Host "Creating aks cluster with name $aksname with version $stableversion"
    $run_command = az aks create -n $aksname -g $rg_name --generate-ssh-keys --node-vm-size Standard_D8s_v3 --node-count 2 --kubernetes-version $StableVersion --enable-cluster-autoscaler --min-count 1 --max-count 5
    Write-Host "AKS cluster created"
}
catch
{
    $errormessage = $_
    
    Write-Host "Script failed creating aks cluster with error :  "
    throw $errormessage
        
}



try
{
    Write-Host "Merging credintial for aks cluster $aksname"
    $run_command = az aks get-credentials --resource-group $rg_name --name $aksname
    write-host "Merge successfully"
}
catch
{
     $errormessage = $_
     throw $errormessage
}

