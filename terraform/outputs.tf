output "acaid" {
  value = azurerm_container_app.azaca.id
}
output "lawid" {
  value = azurerm_log_analytics_workspace.azlaw.id
}
output "acafqdn" {
  value = azurerm_container_app.azaca.latest_revision_fqdn
}
output "acarevname" {
  value = azurerm_container_app.azaca.latest_revision_name
}
