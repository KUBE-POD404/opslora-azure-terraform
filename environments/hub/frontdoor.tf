locals {
  frontdoor_origins = {
    test = {
      endpoint_name      = "afd-opslora-test-${var.location_code}-001"
      origin_group_name  = "og-opslora-test-${var.location_code}-001"
      origin_name        = "origin-appgw-test-${var.location_code}-001"
      route_name         = "route-opslora-test-${var.location_code}-001"
      origin_host_name   = "app-test.opslora.com"
      origin_host_header = "app-test.opslora.com"
    }
    prod = {
      endpoint_name      = "afd-opslora-prod-${var.location_code}-001"
      origin_group_name  = "og-opslora-prod-${var.location_code}-001"
      origin_name        = "origin-appgw-prod-${var.location_code}-001"
      route_name         = "route-opslora-prod-${var.location_code}-001"
      origin_host_name   = "app.opslora.com"
      origin_host_header = "app.opslora.com"
    }
  }
}

resource "azurerm_cdn_frontdoor_profile" "opslora" {
  name                = "afd-${local.prefix}-${local.scope}-${var.location_code}-001"
  resource_group_name = module.resource_groups.names["rg-${local.prefix}-${local.scope}-connectivity-${var.location_code}"]
  sku_name            = "Standard_AzureFrontDoor"
  tags                = var.tags
}

resource "azurerm_cdn_frontdoor_endpoint" "opslora" {
  for_each                 = local.frontdoor_origins
  name                     = each.value.endpoint_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.opslora.id
  enabled                  = true
  tags                     = var.tags
}

resource "azurerm_cdn_frontdoor_origin_group" "opslora" {
  for_each                 = local.frontdoor_origins
  name                     = each.value.origin_group_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.opslora.id
  session_affinity_enabled = false

  load_balancing {
    sample_size                 = 4
    successful_samples_required = 3
  }

  health_probe {
    interval_in_seconds = 100
    path                = "/"
    protocol            = "Https"
    request_type        = "GET"
  }
}

resource "azurerm_cdn_frontdoor_origin" "opslora" {
  for_each                       = local.frontdoor_origins
  name                           = each.value.origin_name
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.opslora[each.key].id
  enabled                        = true
  host_name                      = each.value.origin_host_name
  http_port                      = 80
  https_port                     = 443
  origin_host_header             = each.value.origin_host_header
  priority                       = 1
  weight                         = 1000
  certificate_name_check_enabled = true
}

resource "azurerm_cdn_frontdoor_route" "opslora" {
  for_each                      = local.frontdoor_origins
  name                          = each.value.route_name
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.opslora[each.key].id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.opslora[each.key].id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.opslora[each.key].id]
  enabled                       = true

  forwarding_protocol    = "HttpsOnly"
  https_redirect_enabled = true
  patterns_to_match      = ["/*"]
  supported_protocols    = ["Http", "Https"]

  link_to_default_domain = true
}
