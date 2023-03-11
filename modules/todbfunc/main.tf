# deployment of azure function probably worthwhile to do within VS Code
# https://github.com/c-w/speech-to-text-demo/blob/4dc7aeb549fafdb0d8ecfaef1c20d34602324bd4/infrastructure/main.tf

resource "azurerm_function_app" "app_directtodb" {
  name                       = "directtodb"
  location                   = var.location
  resource_group_name        = var.resourcegroup
  app_service_plan_id        = var.appplanwindows.id
  storage_account_name       = var.storageaccount.name
  storage_account_access_key = var.storageaccount.primary_access_key

  https_only = true

  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.svc_logs.instrumentation_key
    FUNCTIONS_WORKER_RUNTIME       = "node"
    FUNCTIONS_EXTENSION_VERSION    = "~2"
    WEBSITE_NODE_DEFAULT_VERSION   = "~10"
    HASH                           = filesha256(var.code_zip)
    WEBSITE_USE_ZIP                = "${azurerm_storage_blob.code_blob.url}${data.azurerm_storage_account_sas.code_blob_sas.sas}"

    SERVICEBUS_CONNECTION_STRING = azurerm_servicebus_namespace.queues.default_primary_connection_string
    MONGODB_CONNECTION_STRING    = azurerm_cosmosdb_account.metadata_mongodb.connection_strings[0]
    MONGODB_DATABASE             = azurerm_cosmosdb_mongo_database.metadata_db.name
    TRANSCRIPTION_COLLECTION     = azurerm_cosmosdb_mongo_collection.transcription_collection.name
    SPEAKER_COLLECTION           = azurerm_cosmosdb_mongo_collection.speaker_collection.name
    SPEAKER_RECOGNITION_KEY      = azurerm_cognitive_account.speaker_recognition.primary_access_key
    SPEAKER_RECOGNITION_ENDPOINT = azurerm_cognitive_account.speaker_recognition.endpoint
    SPEECH_SERVICE_KEY           = azurerm_cognitive_account.speech_to_text.primary_access_key
    SPEECH_SERVICE_ENDPOINT      = "https://${azurerm_cognitive_account.speech_to_text.location}.cris.ai/api/speechtotext/v2.0"
    STORAGE_CONNECTION_STRING    = azurerm_storage_account.data_storage_account.primary_connection_string
  }

}