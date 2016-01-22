# AWSKinesisFirehose

To add this library to your model, add the following lines to the top of your agent code:

```
#require "AWSRequestV4.class.nut:1.0.0"
#require "AWSKinesisFirehose.class.nut:1.0.0"
```

**Note: [AWSRequestV4](https://github.com/electricimp/AWSRequestV4/) must be loaded.**

This class can be used to send data to an AWS Kinesis Firehose Delivery Stream.

## Class Methods

### constructor(region, accessKeyId, secretAccessKey)

All parameters are strings. Access keys can be generated with IAM.

### putRecord(deliveryStreamName, data, userCallback)

http://docs.aws.amazon.com/firehose/latest/APIReference/API_PutRecord.html

       Parameter       |       Type     | Description
---------------------- | -------------- | -----------
**deliveryStreamName** | string         | Must be at least 1 and no more than 64 characters
**data**               | string or blob | The actual data to be sent - will be automatically base64 encoded
**userCallback**       | function       | Callback function that takes one parameter (a response table)

### putRecordBatch(deliveryStreamName, dataArray, userCallback)

http://docs.aws.amazon.com/firehose/latest/APIReference/API_PutRecordBatch.html

       Parameter       |       Type     | Description
---------------------- | -------------- | -----------
**deliveryStreamName** | string         | Must be at least 1 and no more than 64 characters
**dataArray**          | array          | An array of data objects (each of which may be a string or blob)
**userCallback**       | function       | Callback function that takes one parameter (a response table)

## Example

```squirrel
#require "AWSRequestV4.class.nut:1.0.0"
#require "AWSKinesisFirehose.class.nut:1.0.0"

const ACCESS_KEY_ID = "YOUR_KEY_ID_HERE";
const SECRET_ACCESS_KEY = "YOUR_KEY_HERE";

firehose <- AWSKinesisFirehose("us-west-2", ACCESS_KEY_ID, SECRET_ACCESS_KEY);

// PutRecord
local data = {
  "someData": "look at all this data",
  "moreData": "wow!"
};
firehose.putRecord("myStreamName", http.jsonencode(data), function(response) {
    server.log(response.statuscode + ": " + response.body);
});

// PutRecordBatch
local data2 = "data can be a string";
local data3 = blob();
data3.writestring("or a blob!");
local dataArray = [data, data2, data3];
firehose.putRecordBatch("myStreamName", dataArray, function(response) {
    server.log(response.statuscode + ": " + response.body);
});
```

## Development

This repository uses [git-flow](http://jeffkreeftmeijer.com/2010/why-arent-you-using-git-flow/).
Please make your pull requests to the __develop__ branch.