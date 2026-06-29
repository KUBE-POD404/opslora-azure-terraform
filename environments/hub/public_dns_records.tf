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
    "argocd-test" = {
      ttl     = 300
      records = ["4.188.112.109"]
    }
    "argocd" = {
      ttl     = 300
      records = ["4.224.188.23"]
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

# Hostinger email is used by notification-service SMTP
# (smtp.hostinger.com / notification@opslora.com). When opslora.com
# nameservers moved from Hostinger to Azure DNS, mail authentication records
# must also live in this Azure DNS zone.
resource "azurerm_dns_mx_record" "opslora_mail" {
  name                = "@"
  zone_name           = azurerm_dns_zone.opslora.name
  resource_group_name = azurerm_dns_zone.opslora.resource_group_name
  ttl                 = 300

  record {
    preference = 5
    exchange   = "mx1.hostinger.com"
  }

  record {
    preference = 10
    exchange   = "mx2.hostinger.com"
  }

  tags = var.tags
}

resource "azurerm_dns_txt_record" "opslora_spf" {
  name                = "@"
  zone_name           = azurerm_dns_zone.opslora.name
  resource_group_name = azurerm_dns_zone.opslora.resource_group_name
  ttl                 = 300

  record {
    value = "v=spf1 include:_spf.mail.hostinger.com ~all"
  }

  tags = var.tags
}

resource "azurerm_dns_txt_record" "opslora_dmarc" {
  name                = "_dmarc"
  zone_name           = azurerm_dns_zone.opslora.name
  resource_group_name = azurerm_dns_zone.opslora.resource_group_name
  ttl                 = 300

  record {
    value = "v=DMARC1; p=none; adkim=s; aspf=s"
  }

  tags = var.tags
}
