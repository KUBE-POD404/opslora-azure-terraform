output "names" {
  value = { for name, rg in azurerm_resource_group.this : name => rg.name }
}

output "ids" {
  value = { for name, rg in azurerm_resource_group.this : name => rg.id }
}

