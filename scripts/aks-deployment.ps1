# from user
$subscription = Read-Host -Prompt "Input your subscription Id"
write-Host "Retrieving list of regions"
$allRegions = ((az account list-locations) | convertfrom-json) | sort-object name | select-object name
write-host $allRegions
$region = Read-Host - Prompt "Please input region where you want to host your aks cluster"
$directconnectivity = Read-Host - prompt "Are you using for direct connectivity 'Yes/No'"


# Default value start
$rg_name="levelupaks_lab1"
$StableVersion = "1.22.11"
#Need to automate with variable to catch the stable version for default value
'''
az aks get-versions --location  --$region  orchestrators –o table
'''
if($directconnectivity -eq "Yes")
{
    $aksname = "aksdirect"
}
else{ $aksname = "aksindirect"
}



# Default value End

#az login 
az account set –-subscription "$subscription"

$region
$subscription
$directconnectivity
$aksname


az group create --name $rg_name --location $region


az aks create -n $aksname -g $rg_name --generate-ssh-keys –-node-vm-size Standard_D8s_v3 --node-count 2 --kubernetes-version $StableVersion --enable-cluster-autoscaler --min-count 1 --max-count 5

az aks get-credentials --resource-group $rg_name --name $aksname

