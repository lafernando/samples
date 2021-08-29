import ballerina/http;
import ballerina/uuid;
import ballerina/log;
import ecommerce.commons as x;

http:Client orderMgtClient = check new("http://localhost:8081/OrderMgt");

service /Billing on new http:Listener(8082) {

    resource function post payment(@http:Payload x:Payment payment) returns string|error? {
        http:Response resp = check orderMgtClient->get("/order/" + <@untainted> payment.orderId);
        json payload = check resp.getJsonPayload();
        x:Order orderx = check payload.cloneWithType(x:Order);
        string receiptNumber = uuid:createType4AsString();
        log:printInfo("Billing - OrderId: " + payment.orderId + " ReceiptNumber: " + receiptNumber);
        return receiptNumber;
    }

}
