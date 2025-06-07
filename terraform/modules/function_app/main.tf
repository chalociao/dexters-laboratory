resource "azurerm_storage_account" "funcsa" {
  name                     = var.saname
  resource_group_name      = var.rg_name
  location                 = var.az_region
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "asplan" {
  name                = "funcasplan"
  resource_group_name = var.rg_name
  location            = var.az_region
  os_type = "Linux"
  sku_name = "Y1"
}

resource "azurerm_application_insights" "funclinuxai" {
  name = "applocation-insights-{azurerm_linux_function_app.funcapp.name}"
  location = var.az_region
  resource_group_name = var.rg_name
  application_type = "other"
}

resource "azurerm_linux_function_app" "funcapp" {
  name                       = "func-linux-app"
  resource_group_name        = var.rg_name
  location                   = var.az_region
  storage_account_name       = var.saname
  storage_account_access_key = azurerm_storage_account.funcsa.primary_access_key
  https_only                 = true
  service_plan_id        = azurerm_service_plan.asplan.id
  site_config {
    application_insights_key = azurerm_application_insights.funclinuxai.instrumentation_key
    application_insights_connection_string = azurerm_application_insights.funclinuxai.connection_string
    application_stack {
      python_version = 3.11
    }
  }
  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY" = "${azurerm_application_insights.funclinuxai.instrumentation_key}"
  }
}
