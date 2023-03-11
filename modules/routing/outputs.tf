output "directtodb_namespace" {
  value = azurerm_eventhub_namespace.directToDB
}

output "directtodb_eventhub" {
  value = azurerm_eventhub.directToDB
}

output "mlfromdb_namespace" {
  value = azurerm_eventhub_namespace.MLfromDB
}

output "mlfromdb_eventhub" {
  value = azurerm_eventhub.MLfromDB
}

output "mltodb_namespace" {
  value = azurerm_eventhub_namespace.MLtoDB
}

output "mltodb_eventhub" {
  value = azurerm_eventhub.MLtoDB
}