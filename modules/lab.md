


## Prerequisites

* An [Azure account](https://azure.microsoft.com/free/) with an active subscription.
* Owner permissions within a Resource Group to create resources and manage role assignments.

## Lab Environment Setup - Automated

1. Right-click or `Ctrl + click` the button below to open the Azure Portal in a new window.

    [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fskt680%2Fazurearcsqlmilevelup%2Fmain%2Ftemplates%2Fjumpbox.json)

## Manual Setup

### 1.  Install Client Tools

    (i) Azure CLI
        - Visit https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli and download the latest stable version

    (ii)  ARCData extension for Azure CLI

        -To install run az extension add --name arcdata

        -To upgrade run az extension update --name arcdata

    (iii) Kubectl
        -	For latest version go to https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/
        -	Example download using curl for version 1.24.0 

            - curl -LO https://dl.k8s.io/release/v1.24.0/bin/windows/amd64/kubectl.exe 
            
            Validate by running

            1.	curl -LO https://dl.k8s.io/v1.24.0/bin/windows/amd64/kubectl.exe.sha256
            2.	CertUtil -hashfile kubectl.exe SHA256
            3.	type kubectl.exe.sha256
            4.	kubectl version –client




### 2. [Deploy Azure AKS Cluster](./aks-deployment.md)
### 3. [Deploy Azure Arc Enabled SQL MI with Indirect Connectivity](./indirect.md)
### 4. [Deploy Azure Arc Enabled SQL MI with Direct Connectivity](./direct.md)