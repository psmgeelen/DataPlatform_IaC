# Dit doornemen!
# https://www.maxivanov.io/deploy-azure-functions-with-terraform/
# https://jakewalsh.co.uk/automating-azure-key-vault-and-secrets-using-terraform/

# Configure the Azure provider
provider "azurerm" {
  features {}
}

locals {
  time = formatdate("YYMMDDhhmm", timestamp())
}

# Get Azure details
data "azurerm_client_config" "current" {}

module "prerequisites" {
  source = "./modules/prereqs"
  namespace = var.namespace
  location = var.location
  time = local.time
}

module "routing" {
  source = "./modules/routing"
  namespace = var.namespace
  location = var.location
  time = local.time
  resourcegroup = module.prerequisites.resourcegroup
}

module "iothub" {
  source = "./modules/iothub"
  namespace = var.namespace
  location = var.location
  time = local.time
  resourcegroup = module.prerequisites.resourcegroup
  storageaccount = module.prerequisites.storageaccount
  directtodb_namespace = module.routing.directtodb_namespace
  directtodb_eventhub = module.routing.directtodb_eventhub
}

module "dwh" {
  source = "./modules/db"
  namespace = var.namespace
  location = var.location
  time = local.time
  resourcegroup = module.prerequisites.resourcegroup
  keyvault = module.prerequisites.keyvault
}