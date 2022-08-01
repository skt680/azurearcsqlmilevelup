## Prerequisites

* An [Azure account](https://azure.microsoft.com/free/) with an active subscription.
* Owner permissions within a Resource Group to create resources and manage role assignments.

## Deploy Jumpbox

1. Right-click or `Ctrl + click` the button below to open the Azure Portal in a new window.

    [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fskt680%2Fazurearcsqlmilevelup%2Fmain%2Ftemplates%2Fjumpbox.json)

## Lab Environment Setup - Automated

### Powershell scripts here

## Manual Setup

### 1.  Install Client Tools on Jumpbox

**To install the tools you will need to open Powershell as Administrator**

1.  Azure CLI

    For latest version go to https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli

    ```text
    Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; rm .\AzureCLI.msi
    ```

    **Restart Powershell**

2.  ARCData extension for Azure CLI

    To install run 
    ```text
    az extension add --name arcdata
    ```

    To upgrade run 
    ```text
    az extension update --name arcdata
    ```

3.  Kubectl
    
    For latest version go to https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/
    Example download using curl for version 1.24.0 

    ```text
    curl -LO https://dl.k8s.io/release/v1.24.0/bin/windows/amd64/kubectl.exe
    ```

    Validate by running the following and comparing the two versions in SHA256 format

    ```text
    curl -LO https://dl.k8s.io/v1.24.0/bin/windows/amd64/kubectl.exe.sha256
    CertUtil -hashfile kubectl.exe SHA256
    type kubectl.exe.sha256
    kubectl version –client
    ```

### 2. [Deploy Azure AKS Cluster](./aks-deployment.md)
### 3. [Deploy Azure Arc Enabled SQL MI with Indirect Connectivity](./indirect.md)
### 4. [Deploy Azure Arc Enabled SQL MI with Direct Connectivity](./direct.md)