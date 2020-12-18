import ballerina/grpc;
import ballerina/io;

public function main (string... args) returns error? {
    StreamingCalcServiceClient ep = new("http://localhost:9090");
    grpc:StreamingClient calcClient = check ep->sum(StreamingCalcServiceMessageListener);
    // foreach var i in 1...10 {
    //     check calcClient->send(i);
    // }
    // check calcClient->complete();
    calcClient = check ep->incrementalSum(StreamingCalcServiceMessageListener);
    foreach var i in 1...10 {
        check calcClient->send(i);
    }
    check calcClient->complete();
}

service StreamingCalcServiceMessageListener = service {

    resource function onMessage(int value) {
        io:println("Value: ", value);
    }

    resource function onError(error err) {
        io:println("Error: ", err);
    }

    resource function onComplete() {
        io:println("Complete.");
    }

};
