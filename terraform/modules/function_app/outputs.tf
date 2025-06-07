output "storage_account_id" {
  value = azurerm_storage_account.funcsa.id
}

output "servic_plan_id" {
  value = azurerm_service_plan.asplan.id
}

output "func_app_id" {
  value = azurerm_linux_function_app.funcapp.id
}
