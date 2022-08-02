

# from user
$subscription = Read-Host -Prompt "Input your subscription Id"
$aksname = Read-Host -Prompt "Input your aks cluster"


# Default value start
$rg_name="levelupaks_lab"
$arcextension ="arc-dc-ext"
$arcnamespace = "arc-dc-ns"
$customerlocationserviceaccount = "sa-arc-dc"

# Default value End
az login 
az account set --subscription "$subscription"


# Install required extensions
az extension add --name k8s-extension
az extension add --name connectedk8s
az extension add --name k8s-configuration
az extension add --name customlocation

# Install required providers

az provider register --namespace Microsoft.Kubernetes
az provider register --namespace Microsoft.KubernetesConfiguration
az provider register --namespace Microsoft.ExtendedLocation

# Connect to Azure Direct connection

az connectedk8s connect --name $aksname --resource-group $rg_name

#Create Azure AKS Extension with auto upgrade disabled 
az k8s-extension create --cluster-name $aksname --resource-group $rg_name --name $arcextension --cluster-type connectedClusters --extension-type microsoft.arcdataservices --auto-upgrade false --scope cluster --release-namespace $arcnamespace --config Microsoft.CustomLocation.ServiceAccount=$customerlocationserviceaccount>

# Get principal id from json
az k8s-extension show --resource-group $rg_name --cluster-name $aksname --cluster-type connectedClusters --name $arcextension --query identity.principalId


#Add role assingnment to principal id
az k8s-extension show --resource-group $rg_name --cluster-name $aksname --cluster-type connectedClusters --name $arcextension --query identity.principalId

#Deploy custom location

az customlocation create --resource-group $rg_name --name <Custom Location Name e.g. arc-dc-cl> --namespace <Namespace> --host-resource-id /subscriptions/<Your Subscription Id>/resourceGroups/$rg_name/providers/Microsoft.Kubernetes/connectedClusters/$aksname --cluster-extension-ids /subscriptions/<Your Subscription Id>/resourceGroups/$rg_name/providers/Microsoft.Kubernetes/connectedClusters/aksname/providers/Microsoft.KubernetesConfiguration/extensions/<Extension Name>

# Deploy Data controller using Azure Infrastructure
az arcdata dc create --connectivity-mode direct --name <Data Controller Name e.g. arc-dc> --subscription <Your Subscription Id> --resource-group $rg_name --location <Region> --storage-class managed-premium --profile-name azure-arc-aks-premium-storage --infrastructure azure --custom-location <Custom Location Name> --cluster-name $aksname

## Deploy SQL MI - General Purpose

az sql mi-arc create --name <GP SQL MI Name> --resource-group $rg_name --location <Region> --custom-location <Custom Location Name> --replicas 1 --cores-request "2" --cores-limit "4" --memory-request "4Gi" --memory-limit "8Gi" --storage-class-data "managed-premium" --storage-class-datalogs "managed-premium" --storage-class-logs "managed-premium" --storage-class-backups "azurefile" --volume-size-data 64Gi --volume-size-datalogs 64Gi --volume-size-logs 5Gi --volume-size-backups 64Gi --tier GeneralPurpose --dev --license-type BasePrice


## Deploy SQL MI - Business critical

az sql mi-arc create --name <BC SQL MI Name> --resource-group $rg_name --location <Region> --custom-location <Custom Location Name> --replicas 3 --cores-request "2" --cores-limit "4" --memory-request "4Gi" --memory-limit "8Gi" --storage-class-data "managed-premium" --storage-class-datalogs "managed-premium" --storage-class-logs "managed-premium" --storage-class-backups "azurefile" --volume-size-data 64Gi --volume-size-datalogs 64Gi --volume-size-logs 5Gi --volume-size-backups 64Gi --tier BusinessCritical --dev --license-type BasePrice

## Verify SQL Managed instance deployed

kubectl get services -n <Namespace>