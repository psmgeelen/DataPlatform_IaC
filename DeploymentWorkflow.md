# The DataPlatform 

This document outlines a detailed and sequential list of how to deploy the platform. Lastly it also shares recommendations for maintaining the code. 

[[_TOC_]]

Overview:
1. Deploy with Terraform the core-components
2. Deploy the Azure functions that can be found in the project directories with the correct credentials
3. Use test-script to validate that the platform works.

## 1. Deploying the infrastructure
The platform is developed in Azure but should also be extensible for AWS and GCP. The purpose of the infrastracture is to be a simple, agnostic drop-in for a data-platform with emphasis on streaming data. Below the individual components are outlined,
## 2. Deploying Azure Functions 
The Azure functions are developed using TypeScript and Node.js for the best maintainable code and best performance. There are 3 Azure Functions to consider:

1. The `DirectToDB` function is trigger by the DirectToDB eventhub, on the directtodb namespace, and sends the data as quicly as possible to de Postgres Database
2. The ML route consists is supported with an Azure Function that (1) extracts the data from the Postgres DB and (2) writes back the data that is produced by the ML stack to the Postgres database. 

## 3. Testing the Platform
Check the [test](./test) folder for instructions. 

# Tips for Debug
The overall route is simply checked for regression testing. 
* The IoT hub can write to a blob storage directly and can be monitored with the VS Code extension as can be found [here](https://marketplace.visualstudio.com/items?itemName=vsciot-vscode.azure-iot-toolkit).
* The EventHub can 'capture events' in a blob storage too. When in doubt enable this feature and track the events that are coming through the event hub. 
* Azure Functions have 2 features for monitoring. The generic approach to use Application Insights to monitor the runtime, the second option is to monitor the explicit logging of the application. This logging is and should be part of the programming. Make sure that you don't run out of space, as logging will stop when a certain daily limit of space has been used up by applications. 

## Issues and concerns when Debugging

There were a couple of issues detected during the development of the TerraFrom script:
* There seems to be an issue with the naming of the namespaces and eventhubs that are contained within the namespaces. The seemed to be switched around when assigning the namespace and eventhub naming in the IoT hub deployment, specifically when creating the routing. For simplicity it is recommended to keep the naming of eventhubs and namespaces identical.
* 