data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

locals {
  rg_slug              = lower(var.resource_group_name)
  rg_slug_no_delimiter = replace(local.rg_slug, "-", "")
  acr_name_base        = join("", regexall("[a-z0-9]", lower(var.acr_name)))
  acr_name             = substr("${local.acr_name_base}${random_string.name_suffix.result}", 0, 50)
  container_app_name_base = join("", regexall("[a-z0-9-]", lower(var.container_app_name)))
  container_app_name      = "${substr(local.container_app_name_base, 0, 25)}-${random_string.name_suffix.result}"
}

resource "random_string" "name_suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = var.log_analytics_workspace_name
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_registry" "this" {
  name                = local.acr_name
  resource_group_name = data.azurerm_resource_group.this.name
  location            = data.azurerm_resource_group.this.location
  sku                 = "Basic"
  admin_enabled       = false
}

resource "azurerm_container_app_environment" "this" {
  name                       = var.container_app_environment_name
  location                   = data.azurerm_resource_group.this.location
  resource_group_name        = data.azurerm_resource_group.this.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
}

resource "azurerm_container_app" "this" {
  name                         = local.container_app_name
  resource_group_name          = data.azurerm_resource_group.this.name
  container_app_environment_id = azurerm_container_app_environment.this.id
  revision_mode                = "Single"

  identity {
    type = "SystemAssigned"
  }

  registry {
    server   = azurerm_container_registry.this.login_server
    identity = "system"
  }

  template {
    container {
      name   = local.container_app_name
      image  = "${azurerm_container_registry.this.login_server}/${var.image_name}:${var.image_tag}"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "ASPNETCORE_ENVIRONMENT"
        value = "Production"
      }
    }

    min_replicas = 1
    max_replicas = 1
  }

  ingress {
    external_enabled = true
    target_port      = 8080
    transport        = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}

resource "azurerm_role_assignment" "container_app_pull" {
  scope                = azurerm_container_registry.this.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_container_app.this.identity[0].principal_id
}