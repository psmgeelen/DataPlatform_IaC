# Components of the Data Platform

In this document the individual components are listed. More over an explanation is given into the functionality and purpose within the platform. To begin a brief summary of the platform is provided. 

## Summary Platform
The data platform has the purpose of storing data in a meaningful way, in particular timeseries machine data. The data come into the cloud over the IoT hub. The IoT hub can manage multiple sources, enables data enrichment and pushes the data to the desired namespace. The data is temporarily stored in the Event Hub to provide time for the Azure Function to be triggered and spun up. The Azure function writes the data to the Postgres database with TimescaleDB extension, for a fast, generic and accessible timeseries data-storage. This route is referred to as the DirectToDB route. A second route, or loop, is build around the DB, retrieving data at regular intervals and pushing this through an Event-Grid, sorting the data and pushing it into ML Azure-Functions. The resulting predictions are collected in an Event Hub and then pushed to the Database with an Azure function. 

## 1. DirectToDB route
The DirectToDB route consists out of the aforementioned IoT Hub, the respective namespace and Event hub. Lastly the events are pushed into the Database. All items are produced in the resource-group, credentials are stored in the Azure Key-vault and there is a single storage-account used for the resources respectively. Lastly, Application-Insights and a Linux and Windows app-plan are created to enable the Azure functions. 

### IoT Hub
The IoT hub is a well-thought-out webservice that enables you to connect devices that can post events to the IoT Hub, in order for the IoT Hub to push those on the specific endpoints. Depending on the payload, messages can be routed to one or many endpoints. To be explicit:
* Connection are managed in the form of 'devices'. If you need SAS tokens of one or means of connecting, this is where you need to be. 
* The IoT-hub has a standard endpoint for all messages that is automatically disabled if you create custom endpoints. Endpoints within the IoT hub are connections to e.g. an eventhub or blob-storage. 
* Routes make a pathway between the incoming messages and the endpoints with the use of a filter (route-query). If the route-query is set to `true` then it will accept all incoming messages. Please note that if a message evaluates to true within multiple filters, that this messages will be sent to multiple endpoints. This is a potential point of replication. 
* Fallback routing is an additional feature that enables you to catch events that can be parsed, evaluated or simply didn't fit in any other route-query.
* Lastly there is the option of enrichment, which is done at the level of IoT hub endpoint, meaning that a message passing routing and is delivered at the endpoint within the IoT hub before it enriched. This is mainly used when more information is required down-stream.

#### Configuration IoT Hub
* The main route is enabled by default and the routing-query is set to `true`, parsing all messages by default.
* An example endpoint for a specific data-source is made, called `plant1`, where the routing-query takes all the messages from a device called `plant1` and routes them to this endpoint. Note that this is not in the `body` of the payload but a property of the message. Enrichment is also enabled, giving additional information to the event before passing it to the eventhub.
* A test endpoint is also deployed to make testing a little easier. It takes messages from the `test` device and routes them to the endpoint, which stores the events in a blob-storage. Although the common format is AVRO, the test endpoint stores the events in JSON as this is easier and faster to open. 
* Fallback route is enabled with a blob-storage endpoint called 'failedmessages'

#### Post Installation steps
Create devices in the IoT hub, in particular a:
* Main
* test
* plant1

### DirectToDB Azure Function


### Database, Postgres with TimescaleDB
The database is a Postgres instance configured with the TimescaleDB extension. This setup provides state-of-the-art performance, a managed SaaS instance for the database and the most generic interface SQL interface. The configuration executes the build of the database and enables the external libraries (referred to as `shared_preloaded_libraries` in Azure) parameter, after which it requires the restart of the database. 
#### Post-Installation steps
Please note that the database itself has nog been configured yet. Furthermore, note that by default ALL IP-addresses are blocked. Connecting to the DB with and IDE will require adding your IP-address to the firewall. Lastly, we provide a standard template that installs the relevant extensions and pre-loads some tables and views that are suitable for machine-data. Note that we use a versioned inventory of the meta-data and that we build connections between asset information and telemetry dynamically. The core-concepts to this structure are 'slowly changing dimensions' and 'tidy data'. Other actions that might be required are:
* Adding users and permissions to the specific use-case
* Adding tables, views and relations
* Adding multiple instances to segregate data
#### Considerations/ Data-Management
We strictly advise managing relations in a dynamic manner as the performance penalty is minimal (particularly with the under-the-hood caching) and relationships in data always change over time, therefore joining data in views. When there is sensitive data that never can be joined, it can make sense to use different DB instances within the DB. More over, it is best practise to consolidate data per database/per data-owner. When you have 3 data-owners with different data, it is best to use 3 instances of the DB. This enables silo's, segregated permissions and the ability to change, correct and delete based on data-ownerships. 
