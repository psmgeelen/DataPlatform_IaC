# IoT Hub

#####################
# Prep requirements #
#####################
resource "azurerm_eventhub_authorization_rule" "IoTHubToEventHubtoDB" {
  resource_group_name = var.resourcegroup.name
  namespace_name      = var.directtodb_namespace.name
  eventhub_name       = var.directtodb_eventhub.name
  name                = "IoTHubToEventHubtoDB"
  send                = true

}

resource "azurerm_storage_container" "IoTHubTest" {
  name                  = "iothub${lower(var.namespace)}test"
  storage_account_name  = var.storageaccount.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "IoTHubFailed" {
  name                  = "iothub${lower(var.namespace)}failed"
  storage_account_name  = var.storageaccount.name
  container_access_type = "private"
}


########################################
# Deploy IoT Hub without configuration #
########################################
resource "azurerm_iothub" "main" {
  name                = "${lower(var.namespace)}-main"
  resource_group_name = var.resourcegroup.name
  location            = var.location

  sku {
    name     = "S1"
    capacity = "1"
  }

  tags = {
    environment = "Production"
    route       = "DirectToDB"
  }
}

#####################################
# Configuring Endpoints for IoT Hub #
#####################################
resource "azurerm_iothub_endpoint_storage_container" "payloadtest" {
  resource_group_name = var.resourcegroup.name
  iothub_name         = azurerm_iothub.main.name
  name                = "payloadtest"

  connection_string          = var.storageaccount.primary_blob_connection_string
  batch_frequency_in_seconds = 60
  max_chunk_size_in_bytes    = 10485760
  container_name             = azurerm_storage_container.IoTHubTest.name
  encoding                   = "Json"
  file_name_format           = "{iothub}/{partition}_{YYYY}_{MM}_{DD}_{HH}_{mm}"
}

resource "azurerm_iothub_endpoint_storage_container" "failedmessages" {
  resource_group_name = var.resourcegroup.name
  iothub_name         = azurerm_iothub.main.name
  name                = "failedmessages"

  connection_string          = var.storageaccount.primary_blob_connection_string
  batch_frequency_in_seconds = 60
  max_chunk_size_in_bytes    = 10485760
  container_name             = azurerm_storage_container.IoTHubFailed.name
  encoding                   = "Avro"
  file_name_format           = "{iothub}/{partition}_{YYYY}_{MM}_{DD}_{HH}_{mm}"
}

resource "azurerm_iothub_endpoint_eventhub" "main" {
  resource_group_name = var.resourcegroup.name
  iothub_id = azurerm_iothub.main.id
  name = "main"
  connection_string = azurerm_eventhub_authorization_rule.IoTHubToEventHubtoDB.primary_connection_string

  depends_on = [azurerm_iothub.main]
}

resource "azurerm_iothub_endpoint_eventhub" "plant1" {
  resource_group_name = var.resourcegroup.name
  iothub_id = azurerm_iothub.main.id
  name = "plant1"
  connection_string = azurerm_eventhub_authorization_rule.IoTHubToEventHubtoDB.primary_connection_string

  depends_on = [azurerm_iothub.main]
}

#########################################
# Configuring the routing for endpoints #
#########################################
resource "azurerm_iothub_route" "main" {
  enabled             = true
  endpoint_names      = ["main"]
  iothub_name         = azurerm_iothub.main.name
  name                = "main"
  resource_group_name = var.resourcegroup.name
  source              = "DeviceMessages"
  condition           = "true"

  depends_on = [
    azurerm_iothub.main,
    azurerm_iothub_endpoint_eventhub.main,
    azurerm_iothub_endpoint_eventhub.plant1,
    azurerm_iothub_endpoint_storage_container.failedmessages,
    azurerm_iothub_endpoint_storage_container.payloadtest
  ]
}

resource "azurerm_iothub_route" "payloadtest" {
  enabled             = true
  endpoint_names      = ["payloadtest"]
  iothub_name         = azurerm_iothub.main.name
  name                = "payloadtest"
  resource_group_name = var.resourcegroup.name
  source              = "DeviceMessages"
  condition           = "$connectionDeviceId = 'test'"

  depends_on = [
    azurerm_iothub.main,
    azurerm_iothub_endpoint_eventhub.main,
    azurerm_iothub_endpoint_eventhub.plant1,
    azurerm_iothub_endpoint_storage_container.failedmessages,
    azurerm_iothub_endpoint_storage_container.payloadtest
  ]
}

resource "azurerm_iothub_route" "plant1" {
  enabled             = true
  endpoint_names      = ["plant1"]
  iothub_name         = azurerm_iothub.main.name
  name                = "plant1"
  resource_group_name = var.resourcegroup.name
  source              = "DeviceMessages"
  condition           = "$connectionDeviceId = 'plant1'"

  depends_on = [
    azurerm_iothub.main,
    azurerm_iothub_endpoint_eventhub.main,
    azurerm_iothub_endpoint_eventhub.plant1,
    azurerm_iothub_endpoint_storage_container.failedmessages,
    azurerm_iothub_endpoint_storage_container.payloadtest
  ]
}

####################################################
# Misc Settings like enrichment and fallbackroutes #
####################################################
resource "azurerm_iothub_enrichment" "plant1" {
  resource_group_name = var.resourcegroup.name
  iothub_name         = azurerm_iothub.main.name
  key                 = "plant1"

  value          = "SomeAdditionalCustomerLabel"
  endpoint_names = [azurerm_iothub_endpoint_eventhub.plant1.name]
}

resource "azurerm_iothub_fallback_route" "fail" {
  resource_group_name = var.resourcegroup.name
  iothub_name         = azurerm_iothub.main.name

  condition      = "true"
  endpoint_names = [azurerm_iothub_endpoint_storage_container.failedmessages.name]
  enabled        = true

  depends_on = [azurerm_iothub_endpoint_storage_container.failedmessages]
}