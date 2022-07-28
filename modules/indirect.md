## Deploy Azure Arc Enabled SQL MI with Indirect Connectivity

1.	Login to Azure AD (Run and follow instructions)
a.	az login –use-device-code
2.	Configure your account to be in the scope of the subscription you will be using
a.	az account set –-subscription <Your Subscription>
3.	Check Kubernetes cluster context

kubectl config get-contexts

4.	Use previously deployed Kubernetes cluster contexts

kubectl config use-context <aks name>

verify the nodes are in running

kubectl get nodes


5.	Deploy Data Controller (no Azure resource is created)
a.	az arcdata dc create --connectivity-mode indirect --name <Data Controller Name e.g. arc> --subscription <Your SubscriptionId> --resource-group <RG Name> --location <Region> --profile-name azure-arc-aks-premium-storage --k8s-namespace <Namespace e.g. arc> --use-k8s

ref : 

6.	Verify Data Controller (DC) has been created successfully by ensuring new pods have been created for the DC.
a.	kubectl get pods -n <Namespace>

7.	Deploy a Development Business Critical Arc Enabled SQL MI with 3 replicas, 2 vCores with a maximum of 4, 4GB of memory with a maximum of 8, managed premium storage for everything apart from backups where managed premium is not available (no Azure resource is created).
a.	az sql mi-arc create --name <SQL MI Name> --k8s-namespace <Namespace> --replicas 3 --cores-request "2" --cores-limit "4" --memory-request "4Gi" --memory-limit "8Gi" --storage-class-data "managed-premium" --storage-class-datalogs "managed-premium" --storage-class-logs "managed-premium" --storage-class-backups "azurefile" --volume-size-data 64Gi --volume-size-datalogs 64Gi --volume-size-logs 5Gi --volume-size-backups 64Gi --tier BusinessCritical --dev --license-type BasePrice --use-k8s
 
ref :
