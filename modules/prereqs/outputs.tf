output "resourcegroup" {
  value = azurerm_resource_group.rg
}

output "storageaccount" {
  value = azurerm_storage_account.main_storage
}

output "appinsights" {
  value = azurerm_application_insights.application_insights
}

output "keyvault" {
  value = azurerm_key_vault.main
}

output "appplanwindows" {
  value = azurerm_app_service_plan.app_service_plan_windows
}

output "appplanlinux" {
  value = azurerm_app_service_plan.app_service_plan_linux
}