
# Create Postrgres DB

#Create KeyVault passwords
# not that the username is very specific in Postgres! To make life easier, only use characters.
resource "random_string" "dbUser" {
  length = 20
  number = false
  special = false
}

#Create Key Vault Secret
resource "azurerm_key_vault_secret" "dbUser" {
  name         = "dbUser"
  value        = random_string.dbUser.result
  key_vault_id = var.keyvault.id

}

resource "random_password" "dbPassword" {
  length = 20
  special = true
}

#Create Key Vault Secret
resource "azurerm_key_vault_secret" "dbPassword" {
  name         = "dbPassword"
  value        = random_password.dbPassword.result
  key_vault_id = var.keyvault.id
}

resource "azurerm_postgresql_server" "dwh" {
  name                          = "${lower(var.namespace)}${var.time}dwh"
  resource_group_name           = var.resourcegroup.name
  location                      = var.location
  version                       = "11"
  administrator_login           = azurerm_key_vault_secret.dbUser.value
  administrator_login_password  = azurerm_key_vault_secret.dbPassword.value

  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  public_network_access_enabled     = true
  ssl_enforcement_enabled           = true
  ssl_minimal_tls_version_enforced  = "TLS1_2"

  sku_name   = "B_Gen5_1"
  storage_mb = 32768
}

resource "azurerm_postgresql_database" "data" {
  name      = "data"
  collation = "en_US.utf8"
  charset   = "utf8"
  resource_group_name = var.resourcegroup.name
  server_name = azurerm_postgresql_server.dwh.name
}

resource "azurerm_postgresql_configuration" "timescaledb" {
  name                = "shared_preload_libraries"
  resource_group_name = var.resourcegroup.name
  server_name         = azurerm_postgresql_server.dwh.name
  value               = "timescaledb"

  provisioner "local-exec" {
    command = "az postgres server restart -g ${azurerm_postgresql_server.dwh.resource_group_name} -n ${azurerm_postgresql_server.dwh.name}"
  }
}