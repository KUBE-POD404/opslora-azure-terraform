param(
  [Parameter(Mandatory = $true)]
  [string]$SubscriptionId,

  [Parameter(Mandatory = $false)]
  [string]$Location = "centralindia",

  [Parameter(Mandatory = $false)]
  [string]$ResourceGroupName = "rg-opslora-tfstate-cin",

  [Parameter(Mandatory = $false)]
  [string]$StorageAccountName = "stopsloratfstatecin001",

  [Parameter(Mandatory = $false)]
  [string]$ContainerName = "tfstate"
)

$ErrorActionPreference = "Stop"

az account set --subscription $SubscriptionId

az group create `
  --name $ResourceGroupName `
  --location $Location `
  --tags app=opslora env=hub owner=platform costCenter=opslora dataClassification=internal managedBy=script

az storage account create `
  --name $StorageAccountName `
  --resource-group $ResourceGroupName `
  --location $Location `
  --sku Standard_ZRS `
  --kind StorageV2 `
  --https-only true `
  --allow-blob-public-access false `
  --min-tls-version TLS1_2 `
  --tags app=opslora env=hub owner=platform costCenter=opslora dataClassification=confidential managedBy=script

az storage account blob-service-properties update `
  --account-name $StorageAccountName `
  --resource-group $ResourceGroupName `
  --enable-versioning true `
  --enable-delete-retention true `
  --delete-retention-days 14 `
  --enable-container-delete-retention true `
  --container-delete-retention-days 14

az storage container create `
  --name $ContainerName `
  --account-name $StorageAccountName `
  --auth-mode login

Write-Host "Terraform state bootstrap complete: $ResourceGroupName/$StorageAccountName/$ContainerName"

