## Deploy Azure Arc Enabled SQL MI with Indirect Connectivity (Requires new AKS Cluster from Lab Step 2)

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

6.	Deploy Data Controller using Azure Infrastructure (see **[reference](https://docs.microsoft.com/en-us/cli/azure/arcdata/dc?view=azure-cli-latest)** for more info)

    ```txt
    az arcdata dc create --connectivity-mode indirect --name <Data Controller Name e.g. arc-idc> --subscription <Your Subscription Id> --resource-group <RG Name> --location <Region> --profile-name azure-arc-aks-premium-storage --k8s-namespace <Namespace e.g. arc-idc-ns> --use-k8s
    ```

15.	Verify Data Controller (DC) has been created successfully by ensuring new pods have been created for the DC

    ```txt
    kubectl get pods -n <Namespace>
    ```

16.	Deploy a Development General Purpose Arc Enabled SQL MI with 1 replica, 2 vCores with a maximum of 4, 4GB of memory with a maximum of 8, managed premium storage for everything apart from backups where managed premium is not available  (see **[reference](https://docs.microsoft.com/en-us/cli/azure/sql/mi-arc?view=azure-cli-latest)** for more info)

    ```txt
    az sql mi-arc create --name <SQL MI Name> --k8s-namespace <Namespace> --replicas 1 --cores-request "2" --cores-limit "4" --memory-request "4Gi" --memory-limit "8Gi" --storage-class-data "managed-premium" --storage-class-datalogs "managed-premium" --storage-class-logs "managed-premium" --storage-class-backups "azurefile" --volume-size-data 64Gi --volume-size-datalogs 64Gi --volume-size-logs 5Gi --volume-size-backups 64Gi --tier GeneralPurpose --dev --license-type BasePrice --use-k8s
    ```

17.	Deploy a Development Business Critical Arc Enabled SQL MI with 3 replicas, 2 vCores with a maximum of 4, 4GB of memory with a maximum of 8, managed premium storage for everything apart from backups

    ```txt
    az sql mi-arc create --name <SQL MI Name> --k8s-namespace <Namespace> --replicas 3 --cores-request "2" --cores-limit "4" --memory-request "4Gi" --memory-limit "8Gi" --storage-class-data "managed-premium" --storage-class-datalogs "managed-premium" --storage-class-logs "managed-premium" --storage-class-backups "azurefile" --volume-size-data 64Gi --volume-size-datalogs 64Gi --volume-size-logs 5Gi --volume-size-backups 64Gi --tier BusinessCritical --dev --license-type BasePrice --use-k8s
    ```
