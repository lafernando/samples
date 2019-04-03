import ballerina/http;
import ballerina/log;
import ballerina/io;
import wso2/kafka;

kafka:ProducerConfig kpConf = {
    bootstrapServers: "localhost:9092"
};

kafka:SimpleProducer kprod = new(kpConf);

listener http:Listener httpListener = new(8080);

@http:ServiceConfig { basePath: "/ordermgt" }
service orderMgt on httpListener {

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/order",
        body: "info"
    }
    resource function addOrder(http:Caller caller, http:Request req, json info) returns error? {
        string id = createOrder(info);
        info.__id = id;
        check kprod->send(info.toString().toByteArray("UTF-8"), "orders");
        check caller->respond("Order Added: " + untaint id);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/order/{orderId}"
    }
    resource function findOrder(http:Caller caller, http:Request req, string orderId) returns error? {
        var orderInfo = check getOrder(orderId);
        json payload;
        if (orderInfo is ()) {
            payload = "Order: " + orderId + " cannot be found.";
        } else {
            payload = orderInfo;
        }
        http:Response response = new;
        response.setJsonPayload(untaint payload);
        var result = caller->respond(response);
        if (result is error) {
            log:printError("Error sending response", err = result);
        }
    }

    @http:ResourceConfig {
        methods: ["PUT"],
        path: "/order/{orderId}",
        body: "info"
    }
    resource function updateOrder(http:Caller caller, http:Request req, string orderId, json info) returns error? {
        boolean updated = check updateOrderInfo(orderId, info);
        if (updated) {
            check caller->respond("Order Updated: " + untaint orderId);
        } else {
            check caller->respond("Order not found for updating: " + untaint orderId);
        }
    }

    @http:ResourceConfig {
        methods: ["DELETE"],
        path: "/order/{orderId}"
    }
    resource function cancelOrder(http:Caller caller, http:Request req, string orderId) {
        _ = updateOrderState(orderId, "CANCELLED");
    }
}
