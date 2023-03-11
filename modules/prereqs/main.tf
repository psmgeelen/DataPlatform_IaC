# Get Azure details
data "azurerm_client_config" "current" {}

# Create ResourceGroup
resource "azurerm_resource_group" "rg" {
  name = var.namespace
  location = var.location
  tags = {
    Platform = "Basic"
    DataStream = "Main"
  }
}

# Create Storage account for all resources
resource "azurerm_storage_account" "main_storage" {
  name                     = "${var.time}main"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags = {
    "environment" = "Production"
    "platform" = "main"
  }
}

# Create Azure KeyVault
resource "azurerm_key_vault" "main" {
  name                        = "${var.namespace}"
  location                    = var.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "get", "backup", "delete", "list", "purge", "recover", "restore", "set",
    ]

    storage_permissions = [
      "Get",
    ]
  }

  depends_on = [
    azurerm_storage_account.main_storage
  ]
}

# Create Create Azure Functions
# In order to make proper use of Azure Functions, we need to deploy Applications Insights 2 app=service plans.
# One for linux (python), and one for Node.js (windows version enables in-browser editing)

resource "azurerm_application_insights" "application_insights" {
  name                = "${var.namespace}-application-insights"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "Node.JS"
  depends_on = [
    azurerm_resource_group.rg
  ]
}
# Linux App plan for Python ML functions
resource "azurerm_app_service_plan" "app_service_plan_linux" {
  name                = "${var.namespace}-app-service-plan-linux"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  kind                = "FunctionApp"
  reserved = true # this has to be set to true for Linux. Not related to the Premium Plan
  sku {
    tier = "Dynamic"
    size = "Y1"
  }
  depends_on = [
    azurerm_resource_group.rg
  ]
}

# Windows App plan for Node.js functions
resource "azurerm_app_service_plan" "app_service_plan_windows" {
  name                = "${var.namespace}-app-service-plan-windows"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  kind                = "FunctionApp"
  reserved = false # this has to be set to true for Linux. Not related to the Premium Plan
  sku {
    tier = "Dynamic"
    size = "Y1"
  }
  depends_on = [
    azurerm_resource_group.rg,
    ]
}