import ballerina/http;
import ballerina/log;
import ballerina/uuid;
import ballerinax/choreo as _;

map<Order> orderMap = {};

service /OrderMgt on new http:Listener(8081) {

    resource function post 'order(@http:Payload Order orderx) returns string|error? {
        string orderId = uuid:createType4AsString();
        orderMap[orderId] = orderx;
        log:printInfo("OrderMgt - OrderId: " + orderId + " AccountId: " + orderx.accountId.toString());
        return orderId;
    }

    resource function get 'order/[string orderId]() returns json|error {
        return check orderMap[orderId].cloneWithType(json);
    }

}