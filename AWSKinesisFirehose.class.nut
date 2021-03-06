/**
 * This class can be used to send data to an AWS Kinesis Firehose Delivery Stream.
 *
 * @author Gino Miglio <gino@electricimp.com>
 *
 * @version 1.0.2
 */
class AWSKinesisFirehose {
  static version = [1, 0, 2];

  static SERVICE = "firehose";
  static TARGET_PREFIX = "Firehose_20150804";

  // Size limits
  static MAX_DELIVERY_STREAM_NAME_LEN = 64; // bytes
  static MAX_DATA_BLOB_LEN = 1024000; // bytes
  static MAX_DATA_ARRAY_LEN = 500; // elements

  _awsRequest = null;

  /**
   * @param {string} region
   * @param {string} accessKeyId
   * @param {string} secretAccessKey
   */
  constructor(region, accessKeyId, secretAccessKey) {
    if ("AWSRequestV4" in getroottable()) {
      _awsRequest = AWSRequestV4(SERVICE, region, accessKeyId, secretAccessKey);
    } else {
      throw ("This class requires AWSRequestV4 - please make sure it is loaded.");
    }
  }

  /**
   * Put record onto the stream
   *
   * @param {string} deliveryStreamName
   * @param {string|blob} data
   * @param {function} cb
   * @return {null}
   */
  function putRecord(deliveryStreamName, data, cb) {
    // Validate input length
    if (deliveryStreamName.len() > MAX_DELIVERY_STREAM_NAME_LEN) {
      server.error(format("Delivery stream name must be no more than %d characters.", MAX_DELIVERY_STREAM_NAME_LEN));
      return;
    }

    if (data.len() > MAX_DATA_BLOB_LEN) {
      server.error(format("Data blob length must be no more than %d bytes", MAX_DATA_BLOB_LEN));
      return;
    }

    local headers = {
      "X-Amz-Target": format("%s.PutRecord", TARGET_PREFIX),
      "Content-Type": "application/x-amz-json-1.1"
    };

    local body = {
      "DeliveryStreamName": deliveryStreamName,
      "Record": {
        "Data": http.base64encode(data)
      }
    };

    _awsRequest.post("/", headers, http.jsonencode(body), cb);
  }

  /**
   * Put a batch of records onto the stream
   *
   * @param {string} deliveryStreamName
   * @param {array} dataArray
   * @param {function} cb
   * @return {null}
   */
  function putRecordBatch(deliveryStreamName, dataArray, cb) {
    // Validate input length

    if (deliveryStreamName.len() > MAX_DELIVERY_STREAM_NAME_LEN) {
      server.error(format("Delivery stream name must be no more than %d characters.", MAX_DELIVERY_STREAM_NAME_LEN));
      return false;
    }

    if (dataArray.len() < 1 || dataArray.len() > MAX_DATA_ARRAY_LEN) {
      server.error(format("Data array must contain between 1 and %d elements", MAX_DATA_ARRAY_LEN));
    }

    // Wrap each element in the data array in a "record" object, because why not

    for (local i = 0; i < dataArray.len(); i++) {
      dataArray[i] = {
        "Data": http.base64encode(dataArray[i])
      };
    }

    local headers = {
      "X-Amz-Target": format("%s.PutRecordBatch", TARGET_PREFIX),
      "Content-Type": "application/x-amz-json-1.1"
    };

    local body = {
      "DeliveryStreamName": deliveryStreamName,
      "Records": dataArray
    }

    _awsRequest.post("/", headers, http.jsonencode(body), cb);
  }
}
