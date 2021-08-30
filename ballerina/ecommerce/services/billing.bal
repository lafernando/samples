import ballerina/http;
import ballerina/uuid;
import ballerina/log;

http:Client orderMgtClient = check new("http://localhost:8081/OrderMgt");

service /Billing on new http:Listener(8082) {

    resource function post payment(@http:Payload Payment payment) returns string|error? {
        Order orderx = check orderMgtClient->get("/order/" + <@untainted> payment.orderId);
        string receiptNumber = uuid:createType4AsString();
        log:printInfo("Billing - OrderId: " + payment.orderId + " ReceiptNumber: " + receiptNumber);
        return receiptNumber;
    }

}
