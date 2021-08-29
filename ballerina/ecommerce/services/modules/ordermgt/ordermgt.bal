import ballerina/http;
import ballerina/log;
import ballerina/uuid;
import ecommerce.commons as x;
import ballerinax/choreo as _;

map<x:Order> orderMap = {};

service /OrderMgt on new http:Listener(8081) {

    resource function post 'order(@http:Payload x:Order orderx) returns string|error? {
        string orderId = uuid:createType4AsString();
        orderMap[orderId] = orderx;
        log:printInfo("OrderMgt - OrderId: " + orderId + " AccountId: " + orderx.accountId.toString());
        return orderId;
    }

    resource function get 'order/[string orderId]() returns json|error {
        return check orderMap[orderId].cloneWithType(json);
    }

}