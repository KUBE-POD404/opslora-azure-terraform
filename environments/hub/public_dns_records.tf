locals {
  public_dns_a_records = {
    "@" = {
      ttl     = 300
      records = ["4.224.188.23"]
    }
    "app" = {
      ttl     = 300
      records = ["4.224.188.23"]
    }
    "docs" = {
      ttl     = 300
      records = ["4.224.188.23"]
    }
    "test" = {
      ttl     = 300
      records = ["4.188.112.109"]
    }
    "app-test" = {
      ttl     = 300
      records = ["4.188.112.109"]
    }
    "docs-test" = {
      ttl     = 300
      records = ["4.188.112.109"]
    }
  }
}

resource "azurerm_dns_a_record" "opslora_public" {
  for_each = local.public_dns_a_records

  name                = each.key
  zone_name           = azurerm_dns_zone.opslora.name
  resource_group_name = azurerm_dns_zone.opslora.resource_group_name
  ttl                 = each.value.ttl
  records             = each.value.records
  tags                = var.tags
}
