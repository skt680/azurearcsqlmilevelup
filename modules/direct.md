## Deploy General Purpose and Business Critical Azure Arc Enabled SQL Managed Instances with Direct Connectivity (Requires new AKS Cluster from Lab Step 2)

1.	Login to Azure AD

    Run the following to login from your client using your default web browser
    ```text
    az login
    ```
    Run the following to login from another device or non-default web browser    
      ```text
    az login --use-device-code
    ```

2.	Configure your account to be in the scope of the subscription you will be using

    ```text
    az account set --subscription <Your Subscription Id>
    ```

3.	List Kubernetes cluster contexts from your kubectl config

    ```txt
    kubectl config get-contexts
    ```

4.	Switch context to the AKS Cluster you will be using to deploy the SQL MI

    ```txt
    kubectl config use-context <AKS Name>
    ```

5.  Verify the nodes are running

    ```txt
    kubectl get nodes
    ```

6. Create Resource Group (if you reuse an existing resource group it will modify any metadata but not delete any existing resources)

    ```txt
    az group create --name <RG Name> --location <Region>
    ```

7.	Install required extensions

    ```txt
    az extension add --name k8s-extension
    az extension add --name connectedk8s
    az extension add --name k8s-configuration
    az extension add --name customlocation
    ```

8.	Register required providers

    ```txt
    az provider register --namespace Microsoft.Kubernetes
    az provider register --namespace Microsoft.KubernetesConfiguration
    az provider register --namespace Microsoft.ExtendedLocation
    ```

9.	Create Azure Direct Connection to the AKS Cluster you will be using to deploy the SQL MI and then review your Resource Group

    ```txt
    az connectedk8s connect --name <AKS Name> --resource-group <RG Name>
    ```

10.	Create Azure AKS Extension with auto upgrade disabled (see **[reference](https://docs.microsoft.com/en-us/cli/azure/k8s-extension?view=azure-cli-latest)** for more info)

    ```txt
    az k8s-extension create --cluster-name <AKS Name> --resource-group <RG Name> --name <Extension Name e.g. arc-dc-ext> --cluster-type connectedClusters --extension-type microsoft.arcdataservices --auto-upgrade false --scope cluster --release-namespace <Namespace e.g. arc-dc-ns> --config Microsoft.CustomLocation.ServiceAccount=<Custom Location Service Account e.g. sa-arc-dc>
    ```

11.	Get Principal Id from returned JSON

    ```txt
    ```az k8s-extension show --resource-group <RG Name> --cluster-name <AKSName> --cluster-type connectedClusters --name <Extension Name> --query identity.principalId
    ```

12.	Add role assignment to Principal Id

    ```txt
    az role assignment create --assignee <Principal Id> --role "Contributor" --scope "/subscriptions/<Your Subscription Id>/resourceGroups/<RG Name>"
    ```

13.	Deploy Custom Location (see **[reference](https://docs.microsoft.com/en-us/cli/azure/customlocation?view=azure-cli-latest)** for more info)

    ```txt
    az customlocation create --resource-group <RG Name> --name <Custom Location Name e.g. arc-dc-cl> --namespace <Namespace> --host-resource-id /subscriptions/<Your Subscription Id>/resourceGroups/<RG Name>/providers/Microsoft.Kubernetes/connectedClusters/<AKS Name> --cluster-extension-ids /subscriptions/<Your Subscription Id>/resourceGroups/<RG Name>/providers/Microsoft.Kubernetes/connectedClusters/<AKS Name>/providers/Microsoft.KubernetesConfiguration/extensions/<Extension Name>
    ```

14.	Deploy Data Controller using Azure Infrastructure (see **[reference](https://docs.microsoft.com/en-us/cli/azure/arcdata/dc?view=azure-cli-latest)** for more info)

    ```txt
    az arcdata dc create --connectivity-mode direct --name <Data Controller Name e.g. arc-dc> --subscription <Your Subscription Id> --resource-group <RG Name> --location <Region> --storage-class managed-premium --profile-name azure-arc-aks-premium-storage --infrastructure azure --custom-location <Custom Location Name> --cluster-name <AKS Name>
    ```

15.	Verify Data Controller (DC) has been created successfully by ensuring new pods have been created for the DC.

    ```txt
    kubectl get pods -n <Namespace>
    ```

16.	Deploy a Development General Purpose Arc Enabled SQL MI with 1 replica, 2 vCores with a maximum of 4, 4GB of memory with a maximum of 8, managed premium storage for everything apart from backups where managed premium is not available (see **[reference](https://docs.microsoft.com/en-us/cli/azure/sql/mi-arc?view=azure-cli-latest)** for more info)

    ```txt
    az sql mi-arc create --name <GP SQL MI Name> --resource-group <RG Name> --location <Region> --custom-location <Custom Location Name> --replicas 1 --cores-request "2" --cores-limit "4" --memory-request "4Gi" --memory-limit "8Gi" --storage-class-data "managed-premium" --storage-class-datalogs "managed-premium" --storage-class-logs "managed-premium" --storage-class-backups "azurefile" --volume-size-data 64Gi --volume-size-datalogs 64Gi --volume-size-logs 5Gi --volume-size-backups 64Gi --tier GeneralPurpose --dev --license-type BasePrice
    ```

17.	Deploy a Development Business Critical Arc Enabled SQL MI with 3 replicas, 2 vCores with a maximum of 4, 4GB of memory with a maximum of 8, managed premium storage for everything apart from backups

    ```txt
    az sql mi-arc create --name <BC SQL MI Name> --resource-group <RG Name> --location <Region> --custom-location <Custom Location Name> --replicas 3 --cores-request "2" --cores-limit "4" --memory-request "4Gi" --memory-limit "8Gi" --storage-class-data "managed-premium" --storage-class-datalogs "managed-premium" --storage-class-logs "managed-premium" --storage-class-backups "azurefile" --volume-size-data 64Gi --volume-size-datalogs 64Gi --volume-size-logs 5Gi --volume-size-backups 64Gi --tier BusinessCritical --dev --license-type BasePrice
    ```

18. Verify both Managed Instances were successfully created

    ```txt
    kubectl get services -n <Namespace>
    ```

    Look for entries for \<GP SQL MI Name\>-external-svc and \<BC SQL MI Name\>-external-svc and note the Public IP Addresses (EXTERNAL-IP)

    You can connect to these IP Addresses using SQL Server Management Studio and Azure Data Studio
