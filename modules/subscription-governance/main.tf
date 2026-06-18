locals {
  subscription_scope = "/subscriptions/${var.subscription_id}"

  key_vault_public_network_effect_parameter = jsonencode({
    effect = {
      value = var.key_vault_public_network_effect
    }
  })

  aks_workload_identity_effect_parameter = jsonencode({
    effect = {
      value = var.aks_workload_identity_effect
    }
  })
}

resource "azurerm_role_assignment" "admin_owner" {
  for_each = var.enable_admin_owner_role_assignments ? toset(var.admin_principal_object_ids) : toset([])

  scope                = local.subscription_scope
  role_definition_name = "Owner"
  principal_id         = each.value
}

resource "azurerm_policy_definition" "audit_allowed_locations" {
  count = var.enable_policy_assignments ? 1 : 0

  name         = "poldef-opslora-${var.scope_name}-audit-allowed-locations"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Opslora audit allowed locations - ${var.scope_name}"
  description  = "Audits resources deployed outside Opslora approved Azure locations."

  metadata = jsonencode({
    category = "Opslora Governance"
  })

  parameters = jsonencode({
    allowedLocations = {
      type = "Array"
      metadata = {
        displayName = "Allowed locations"
      }
    }
    effect = {
      type          = "String"
      defaultValue  = "Audit"
      allowedValues = ["Audit", "Deny", "Disabled"]
      metadata = {
        displayName = "Effect"
      }
    }
  })

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "location"
          exists = "true"
        },
        {
          field = "location"
          notIn = "[parameters('allowedLocations')]"
        }
      ]
    }
    then = {
      effect = "[parameters('effect')]"
    }
  })
}

resource "azurerm_subscription_policy_assignment" "audit_allowed_locations" {
  count = var.enable_policy_assignments ? 1 : 0

  name                 = "polasgn-opslora-${var.scope_name}-allowed-locations-001"
  display_name         = "Opslora audit allowed locations - ${var.scope_name}"
  policy_definition_id = azurerm_policy_definition.audit_allowed_locations[0].id
  subscription_id      = local.subscription_scope
  location             = var.location

  parameters = jsonencode({
    allowedLocations = {
      value = var.allowed_locations
    }
    effect = {
      value = var.policy_effect
    }
  })

  non_compliance_message {
    content = "Resource location is outside the Opslora approved region list."
  }
}

resource "azurerm_policy_definition" "audit_required_tag" {
  count = var.enable_policy_assignments ? 1 : 0

  name         = "poldef-opslora-${var.scope_name}-audit-required-tag"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Opslora audit required tag - ${var.scope_name}"
  description  = "Audits resources missing an Opslora required tag."

  metadata = jsonencode({
    category = "Opslora Governance"
  })

  parameters = jsonencode({
    tagName = {
      type = "String"
      metadata = {
        displayName = "Tag name"
      }
    }
    effect = {
      type          = "String"
      defaultValue  = "Audit"
      allowedValues = ["Audit", "Deny", "Disabled"]
      metadata = {
        displayName = "Effect"
      }
    }
  })

  policy_rule = jsonencode({
    if = {
      field  = "[concat('tags[', parameters('tagName'), ']')]"
      exists = "false"
    }
    then = {
      effect = "[parameters('effect')]"
    }
  })
}

resource "azurerm_subscription_policy_assignment" "audit_required_tags" {
  for_each = var.enable_policy_assignments ? toset(var.required_tags) : toset([])

  name                 = "polasgn-opslora-${var.scope_name}-tag-${lower(each.value)}-001"
  display_name         = "Opslora audit required tag ${each.value} - ${var.scope_name}"
  policy_definition_id = azurerm_policy_definition.audit_required_tag[0].id
  subscription_id      = local.subscription_scope
  location             = var.location

  parameters = jsonencode({
    tagName = {
      value = each.value
    }
    effect = {
      value = var.policy_effect
    }
  })

  non_compliance_message {
    content = "Resource is missing the required Opslora tag '${each.value}'."
  }
}

data "azurerm_policy_definition" "key_vault_disable_public_network" {
  count = var.enable_policy_assignments ? 1 : 0

  name = "405c5871-3e91-4644-8a63-58e19d68ff5b"
}

resource "azurerm_subscription_policy_assignment" "audit_key_vault_public_network" {
  count = var.enable_policy_assignments ? 1 : 0

  name                 = "polasgn-opslora-${var.scope_name}-audit-kv-public-network-001"
  display_name         = "Opslora audit Key Vault public network access - ${var.scope_name}"
  policy_definition_id = data.azurerm_policy_definition.key_vault_disable_public_network[0].id
  subscription_id      = local.subscription_scope
  location             = var.location
  parameters           = local.key_vault_public_network_effect_parameter

  non_compliance_message {
    content = "Key Vault public network access should be disabled after bootstrap."
  }
}

data "azurerm_policy_definition" "aks_workload_identity" {
  count = var.enable_policy_assignments ? 1 : 0

  name = "2cc2e023-0dac-4046-875b-178f683929d5"
}

resource "azurerm_subscription_policy_assignment" "audit_aks_workload_identity" {
  count = var.enable_policy_assignments ? 1 : 0

  name                 = "polasgn-opslora-${var.scope_name}-audit-aks-workload-id-001"
  display_name         = "Opslora audit AKS Workload Identity - ${var.scope_name}"
  policy_definition_id = data.azurerm_policy_definition.aks_workload_identity[0].id
  subscription_id      = local.subscription_scope
  location             = var.location
  parameters           = local.aks_workload_identity_effect_parameter

  non_compliance_message {
    content = "AKS clusters should enable Workload Identity."
  }
}
