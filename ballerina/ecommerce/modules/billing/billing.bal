import ballerina/http;
import ballerina/system;
import ballerina/log;
import laf/commons as x;

http:Client orderMgtClient = new("http://localhost:8081/OrderMgt");

service Billing on new http:Listener(8082) {

    @http:ResourceConfig {
        path: "/payment",
        body: "payment",
        methods: ["POST"]
    }
    resource function processPayment(http:Caller caller, http:Request request, 
                                     x:Payment payment) returns @tainted error? {
        http:Response resp = check orderMgtClient->get("/order/" + <@untainted> payment.orderId);
        x:Order order = check x:Order.constructFrom(check resp.getJsonPayload());
        string receiptNumber = system:uuid();
        check caller->respond(receiptNumber);
        log:printInfo("Billing - OrderId: " + payment.orderId + " ReceiptNumber: " + receiptNumber);
    }

}