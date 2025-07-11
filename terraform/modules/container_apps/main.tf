resource "azurerm_resource_group" "azrg" {
  name     = var.rg_name
  location = var.az_region
}

resource "azurerm_log_analytics_workspace" "azlaw" {
  name                = var.law_name
  location            = azurerm_resource_group.azrg.location
  resource_group_name = azurerm_resource_group.azrg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "azacae" {
  name                = "acae0406"
  location            = azurerm_resource_group.azrg.location
  resource_group_name = azurerm_resource_group.azrg.name
}

resource "azurerm_container_app" "azaca" {
  name                         = "aca0406"
  container_app_environment_id = azurerm_container_app_environment.azacae.id
  resource_group_name          = azurerm_resource_group.azrg.name
  revision_mode                = "Single"
  template {
    container {
      name   = "acacontainerapp"
      image  = "mcr.microsoft.com/k8se/quickstart:latest"
      cpu    = "0.25"
      memory = "0.5Gi"
    }
  }
  ingress {
    allow_insecure_connections = false
    target_port                = 80
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
    external_enabled = true
  }
}
