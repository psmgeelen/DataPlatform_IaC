https://stackoverflow.com/questions/62093230/sending-data-to-azure-iot-hub-using-rest

https://thomastropper.com/general/azure-iot-hub-rest-api-testing-with-postman/

Example code
```shell
curl --location --request POST 'https://dataaccelerator-main.azure-devices.net/devices/plant1/messages/events?api-version=2018-06-30' \
--header 'Authorization: SharedAccessSignature sr=dataaccelerator-main.azure-devices.net%2Fdevices%2Fplant1&sig=hQl1Wm7uMy2qd%2BTHvhLILgWgnCZeAdvts4aJFuBitjo%3D&se=1640565742' \
--header 'Content-Type: application/json' \
--data-raw '{
    "Weather": {
        "Temperature": 50
    },
    "Location": {
        "State": "Washington"
    },
    "somedumbshit":"yolo"
}'
```