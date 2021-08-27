import ballerina/http;
import ballerina/url;
import ecommerce.commons as x;

http:Client cartClient = check new("http://localhost:8080/ShoppingCart");
http:Client orderMgtClient = check new("http://localhost:8081/OrderMgt");
http:Client billingClient = check new("http://localhost:8082/Billing");
http:Client shippingClient = check new("http://localhost:8083/Shipping");
http:Client invClient = check new("http://localhost:8084/Inventory");

type ItemArray x:Item[];

service /admin on new http:Listener(8085) {

    resource function get invsearch/[string query]() returns json|error? {
        json resp = check invClient->get("/search/" + check url:encode(query, "UTF-8"));
        return resp;
    }

    resource function post cartitems/[int accountId](@http:Payload x:Item item) returns json|error? {
        json resp = check cartClient->post("/items/" + accountId.toString(), check item.cloneWithType(json));
        return resp;
    }

    resource function get checkout/[int accountId]() returns http:Response|json|error? {
        http:Response resp = check cartClient->get("/items/" + accountId.toString());
        json payload = check resp.getJsonPayload();
        x:Item[] items = check payload.cloneWithType(ItemArray);
        if items.length() == 0 {
            http:Response respx = new;
            respx.statusCode = 400;
            respx.setTextPayload("Empty cart");
            return respx;
        }
        x:Order orderx = { accountId, items };
        resp = check orderMgtClient->post("/order", check orderx.cloneWithType(json));
        string orderId = check resp.getTextPayload();
        x:Payment payment = { orderId };
        resp = check billingClient->post("/payment", check payment.cloneWithType(json));
        string receiptNumber = check resp.getTextPayload();
        x:Delivery delivery = { orderId };
        resp = check shippingClient->post("/delivery", check delivery.cloneWithType(json));
        string trackingNumber = check resp.getTextPayload();
        () x = check cartClient->delete("/items/" + accountId.toString());
        return { accountId: accountId, orderId: orderId, receiptNumber: receiptNumber, 
                                trackingNumber: trackingNumber };
    }

}