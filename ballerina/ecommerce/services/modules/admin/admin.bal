import ballerina/http;
import ballerina/url;
import ecommerce.commons as x;
import ballerinax/choreo as _;

http:Client cartClient = check new("http://localhost:8080/ShoppingCart");
http:Client orderMgtClient = check new("http://localhost:8081/OrderMgt");
http:Client billingClient = check new("http://localhost:8082/Billing");
http:Client shippingClient = check new("http://localhost:8083/Shipping");
http:Client invClient = check new("http://localhost:8084/Inventory");

type ItemArray x:Item[];

service /Admin on new http:Listener(8085) {

    resource function get invsearch/[string query]() returns json|error? {
        json resp = check invClient->get("/search/" + check url:encode(query, "UTF-8"));
        return resp;
    }

    resource function post cartitems/[int accountId](@http:Payload x:Item item) returns error? {
        _ = check cartClient->post("/items/" + accountId.toString(), check item.cloneWithType(json), targetType = http:Response);
    }

    resource function get checkout/[int accountId]() returns http:Response|json|error? {
        json payload = check cartClient->get("/items/" + accountId.toString());
        x:Item[] items = check payload.cloneWithType(ItemArray);
        if items.length() == 0 {
            http:Response respx = new;
            respx.statusCode = 400;
            respx.setTextPayload("Empty cart");
            return respx;
        }
        x:Order orderx = { accountId, items };
        string orderId = check orderMgtClient->post("/order", check orderx.cloneWithType(json));
        x:Payment payment = { orderId };
        string receiptNumber = check billingClient->post("/payment", check payment.cloneWithType(json));
        x:Delivery delivery = { orderId };
        string trackingNumber = check shippingClient->post("/delivery", check delivery.cloneWithType(json));
        _ = check cartClient->delete("/items/" + accountId.toString(), targetType = http:Response);
        return { accountId: accountId, orderId: orderId, receiptNumber: receiptNumber, 
                                trackingNumber: trackingNumber };
    }

}