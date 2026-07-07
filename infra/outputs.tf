output "resource_group_name" {
  value = data.azurerm_resource_group.this.name
}

output "acr_login_server" {
  value = azurerm_container_registry.this.login_server
}

output "container_app_url" {
  value = "https://${azurerm_container_app.this.latest_revision_fqdn}"
}

output "container_app_name" {
  value = azurerm_container_app.this.name
}