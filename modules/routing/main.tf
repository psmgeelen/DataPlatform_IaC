resource "azurerm_eventhub_namespace" "directToDB" {
  name                = "directtodb"
  location            = var.location
  resource_group_name = var.resourcegroup.name
  sku                 = "Standard"
  capacity            = 1

  tags = {
    environment = "Production"
    route = "DirectToDB"
  }
}

resource "azurerm_eventhub" "directToDB" {
  name                = "directtodb"
  namespace_name      = azurerm_eventhub_namespace.directToDB.name
  resource_group_name = var.resourcegroup.name
  partition_count     = 2
  message_retention   = 1
  depends_on = [
    azurerm_eventhub_namespace.directToDB
  ]
}


resource "azurerm_eventhub_namespace" "MLfromDB" {
  name                = "mlfromdb"
  location            = var.location
  resource_group_name = var.resourcegroup.name
  sku                 = "Standard"
  capacity            = 1

  tags = {
    environment = "Production"
    route = "ML"
  }
}

resource "azurerm_eventhub" "MLfromDB" {
  name                = "mlfromdb"
  namespace_name      = azurerm_eventhub_namespace.MLfromDB.name
  resource_group_name = var.resourcegroup.name
  partition_count     = 2
  message_retention   = 1
  depends_on = [
    azurerm_eventhub_namespace.MLfromDB
  ]

}

resource "azurerm_eventhub_namespace" "MLtoDB" {
  name                = "mltodb"
  location            = var.location
  resource_group_name = var.resourcegroup.name
  sku                 = "Standard"
  capacity            = 1

  tags = {
    environment = "Production"
    route = "ML"
  }
}

resource "azurerm_eventhub" "MLtoDB" {
  name                = "mltodb"
  namespace_name      = azurerm_eventhub_namespace.MLtoDB.name
  resource_group_name = var.resourcegroup.name
  partition_count     = 2
  message_retention   = 1
  depends_on = [
    azurerm_eventhub_namespace.MLtoDB
  ]
}
