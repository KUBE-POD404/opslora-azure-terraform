output "id" {
  value = azurerm_kubernetes_cluster.this.id
}

output "name" {
  value = azurerm_kubernetes_cluster.this.name
}

output "kubelet_identity_object_id" {
  value = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}

output "oidc_issuer_url" {
  value = azurerm_kubernetes_cluster.this.oidc_issuer_url
}

output "key_vault_secrets_provider_client_id" {
  value = azurerm_kubernetes_cluster.this.key_vault_secrets_provider[0].secret_identity[0].client_id
}

output "key_vault_secrets_provider_object_id" {
  value = azurerm_kubernetes_cluster.this.key_vault_secrets_provider[0].secret_identity[0].object_id
}

output "agic_client_id" {
  value = azurerm_kubernetes_cluster.this.ingress_application_gateway[0].ingress_application_gateway_identity[0].client_id
}

output "agic_object_id" {
  value = azurerm_kubernetes_cluster.this.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
}
