import ballerina/http;
import ballerina/log;
import ballerina/uuid;
import ballerinax/choreo as _;

http:Client ordermgtClient = check new("http://localhost:8081/OrderMgt");

service /Shipping on new http:Listener(8083) {

    resource function post delivery(@http:Payload Delivery delivery) returns string|error {
        http:Response resp = check ordermgtClient->get("/order/" + delivery.orderId);
        json payload = check resp.getJsonPayload();
        Order orderx = check payload.cloneWithType(Order);
        string trackingNumber = uuid:createType4AsString();
        log:printInfo("Shipping - OrderId: " + delivery.orderId + " TrackingNumber: " + trackingNumber);
        return trackingNumber;
    }

}
