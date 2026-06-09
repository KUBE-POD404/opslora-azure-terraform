resource "azurerm_public_ip_prefix" "hub" {
  name                = "pip-prefix-opslora-hub-${var.location_code}-28"
  location            = var.location
  resource_group_name = var.resource_group_name
  prefix_length       = 28
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
  tags                = var.tags
}

resource "azurerm_public_ip" "firewall" {
  name                = "pip-opslora-fw-${var.location_code}-001"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
  public_ip_prefix_id = azurerm_public_ip_prefix.hub.id
  tags                = var.tags
}

resource "azurerm_firewall_policy" "this" {
  name                = "fwpol-opslora-hub-${var.location_code}-001"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_firewall_policy_rule_collection_group" "baseline" {
  name               = "fwrcg-opslora-hub-baseline-${var.location_code}-001"
  firewall_policy_id = azurerm_firewall_policy.this.id
  priority           = 100

  network_rule_collection {
    name     = "allow-required-outbound"
    priority = 100
    action   = "Allow"

    rule {
      name                  = "allow-http-https-dns"
      protocols             = ["TCP", "UDP"]
      source_addresses      = ["10.40.0.0/20", "10.41.0.0/20"]
      destination_addresses = ["*"]
      destination_ports     = ["53", "80", "443", "123"]
    }
  }
}

resource "azurerm_firewall" "this" {
  name                = "fw-opslora-hub-${var.location_code}-001"
  location            = var.location
  resource_group_name = var.firewall_resource_group_name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  firewall_policy_id  = azurerm_firewall_policy.this.id
  zones               = ["1", "2", "3"]
  tags                = var.tags

  ip_configuration {
    name                 = "ipconfig"
    subnet_id            = var.firewall_subnet_id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }
}
