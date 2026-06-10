output "admin_owner_assignment_ids" {
  value       = { for key, assignment in azurerm_role_assignment.admin_owner : key => assignment.id }
  description = "Owner role assignment IDs for admin principals."
}

output "policy_assignment_ids" {
  value = {
    allowed_locations       = try(azurerm_subscription_policy_assignment.audit_allowed_locations[0].id, null)
    required_tags           = { for key, assignment in azurerm_subscription_policy_assignment.audit_required_tags : key => assignment.id }
    key_vault_public_access = try(azurerm_subscription_policy_assignment.audit_key_vault_public_network[0].id, null)
    aks_workload_identity   = try(azurerm_subscription_policy_assignment.audit_aks_workload_identity[0].id, null)
  }
  description = "Audit-mode policy assignment IDs."
}
