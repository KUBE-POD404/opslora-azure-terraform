resource "azurerm_public_ip" "bastion" {
  count = var.enable_bastion ? 1 : 0

  name                = "pip-opslora-bastion-${var.location_code}-001"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
  tags                = var.tags
}

resource "azurerm_bastion_host" "this" {
  count = var.enable_bastion ? 1 : 0

  name                = "bas-opslora-hub-${var.location_code}-001"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  copy_paste_enabled  = true
  tags                = var.tags

  ip_configuration {
    name                 = "ipconfig"
    subnet_id            = var.bastion_subnet_id
    public_ip_address_id = azurerm_public_ip.bastion[0].id
  }
}
