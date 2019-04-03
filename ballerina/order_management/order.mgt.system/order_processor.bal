import wso2/kafka;
import ballerina/io;
import ballerina/encoding;
import ballerina/runtime;

kafka:ConsumerConfig conf = {
    bootstrapServers: "localhost:9092",
    groupId: "order_processor",
    topics: ["orders"]
};

listener kafka:SimpleConsumer consumer = new(conf);

service kafkaService on consumer {
    resource function onMessage(kafka:SimpleConsumer simpleConsumer, kafka:ConsumerRecord[] records) {
        foreach var rec in records {
            string val = encoding:byteArrayToString(rec.value, encoding = "utf-8");
            var entry = parseJson(val);
            if (entry is json) {
                _ = start processOrder(entry);
            }
        }
    }
}

function processOrder(json entry) {
    io:println("Processing Order: ", entry);
    runtime:sleep(10000);
    var result = updateOrderState(entry.__id.toString(), "PROCESSED");
    if (result is error) {
        io:println("Error: ", result);
    } else {
        io:println("Order Processed: ", entry.__id);
    }
}

function parseJson(string data) returns json|error {
    io:StringReader reader = new(data);
    return reader.readJson();
}