param(
  [Parameter(Mandatory = $true)]
  [string]$SubscriptionId,

  [Parameter(Mandatory = $false)]
  [string]$Location = "centralindia"
)

$ErrorActionPreference = "Stop"

az account set --subscription $SubscriptionId

$sizes = @(
  "Standard_D2s_v5",
  "Standard_D4s_v5",
  "Standard_D2as_v5",
  "Standard_D4as_v5"
)

foreach ($size in $sizes) {
  Write-Host "Checking VM size: $size"
  az vm list-skus `
    --location $Location `
    --size $size `
    --resource-type virtualMachines `
    --all `
    --output table
}

Write-Host "Checking Application Gateway WAF_v2 availability"
az network application-gateway waf-policy list --output table | Out-Null
Write-Host "If no error was returned, network provider calls are available. Confirm WAF_v2 at plan time."

Write-Host "Checking MySQL Flexible Server locations"
az mysql flexible-server list-skus --location $Location --output table

