resource "azurerm_resource_group" "azrg" {
  name     = var.rg_name
  location = var.az_region
}
module "container_app" {
  source    = "./modules/container_apps"
  law_name  = var.law_name
  rg_name   = var.rg_name
  az_region = var.az_region
}

module "function_app" {
  source    = "./modules/function_app"
  saname    = var.saname
  rg_name   = var.rg_name
  az_region = var.az_region
}
