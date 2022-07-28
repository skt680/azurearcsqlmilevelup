### Deploy Azure Arc Enabled SQL MI with Direct Connectivity


1.	Login to Azure AD (Run and follow instructions)
a.	az login –use-device-code
2.	Configure your account to be in the scope of the subscription you will be using
a.	az account set –-subscription <Your Subscription>
3.	Create Resource Group
a.	az group create --name <RG Name> --location <Region>

4.	Check Kubernetes cluster context

kubectl config get-contexts

5.	Use previously deployed Kubernetes cluster contexts

kubectl config use-context <aks name>

verify the nodes are in running

kubectl get nodes

6.	Install required extensions
az extension add --name k8s-extension
az extension add --name connectedk8s
az extension add --name k8s-configuration
az extension add --name customlocation
7.	Register required providers
az provider register --namespace Microsoft.Kubernetes
az provider register --namespace Microsoft.KubernetesConfiguration
az provider register --namespace Microsoft.ExtendedLocation
8.	Create Azure Direct Connection to AKS (creates resource)
az connectedk8s connect --name <AKS Name> --resource-group <RG Name>
9.	Create Azure AKS Extension with auto upgrade disabled
az k8s-extension create --cluster-name <AKS Name> --resource-group <RG Name> --name <Extension Name e.g. arcext> -–cluster-type connectedClusters --extension-type microsoft.arcdataservices --auto-upgrade false --scope cluster --release-namespace <Namespace e.g. arc> --config Microsoft.CustomLocation.ServiceAccount=<Custom Location Service Account e.g. sa-arc-bootstrapper>
ref :

10.	Get Principal ID from returned JSON
11.	Add role assignments for Grafana and Kibana
az role assignment create --assignee <Principal Id> --role "Contributor" --scope "/subscriptions/<Your Subscription Id>/resourceGroups/<RG Name>"
az role assignment create --assignee <Principal Id> --role "Monitoring Metrics Publisher" --scope "/subscriptions/<Your Subscription Id>/resourceGroups/<RG Name>"
12.	Deploy Custom Location
az customlocation create --resource-group <RG Name> --name <Custom Location Name e.g. arc> --namespace <Namespace> --host-resource-id /subscriptions/<Your Subscription Id>/resourceGroups/<RG Name>/providers/Microsoft.Kubernetes/connectedClusters/<AKS Name> --cluster-extension-ids /subscriptions/<Your Subscription Id>/resourceGroups/<RG Name> /providers/Microsoft.Kubernetes/connectedClusters/<AKS Name>/providers/Microsoft.KubernetesConfiguration/extensions/<Extension Name>
ref :

13.	Deploy Data Controller using Azure Infrastructure, auto upload metrics and logs
az arcdata dc create --connectivity-mode direct --name <Data Controller Name e.g. arc-dc> --subscription <Your Subscription Id> --resource-group <RG Name> --location <Region> --storage-class managed-premium --profile-name azure-arc-aks-premium-storage --infrastructure azure --custom-location <Custom Location Name> --cluster-name <AKS Name> --auto-upload-metrics true --auto-upload-logs true
ref :

14.	Verify Data Controller (DC) has been created successfully by ensuring new pods have been created for the DC.
a.	kubectl get pods -n <Namespace>

15.	Deploy a Development Business Critical Arc Enabled SQL MI with 3 replicas, 2 vCores with a maximum of 4, 4GB of memory with a maximum of 8, managed premium storage for everything apart from backups where managed premium is not available (no Azure resource is created).
a.	az sql mi-arc create --name <SQL MI Name> --resource-group <RG Name> --location <Region> --custom-location <Custom Location Name> --replicas 3 --cores-request "2" --cores-limit "4" --memory-request "4Gi" --memory-limit "8Gi" --storage-class-data "managed-premium" --storage-class-datalogs "managed-premium" --storage-class-logs "managed-premium" --storage-class-backups "azurefile" --volume-size-data 64Gi --volume-size-datalogs 64Gi --volume-size-logs 5Gi --volume-size-backups 64Gi --tier BusinessCritical --dev --license-type BasePrice --use-k8s
